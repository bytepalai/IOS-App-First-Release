//
//  FacebookLoginButton.swift
//  BytePal
//
//  Created by Scott Hom on 11/5/20.
//  Copyright © 2020 BytePal-AI. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData
import FBSDKCoreKit
import FBSDKLoginKit

// FacebookLoginButton (height: 7%)
struct FacebookLoginButton: View {
    
    // Arguments
    
    //// Dynamic sizing
    var width: CGFloat?
    
    //// Navigation by changing if views are shown
    @Binding var isHiddenLoginView: Bool
    @Binding var isHiddenChatView: Bool
    
    // BytePal Objects
    
    // Core Data
    
    // Environment Object
    
    // Observable Objects
    
    // States
    
    
    
    var container: NSPersistentContainer!
    
    @FetchRequest(entity: User.entity(), sortDescriptors: []) var UserInformationCoreDataRead: FetchedResults<User>
    @FetchRequest(entity: Message.entity(), sortDescriptors: []) var MessagesCoreDataRead: FetchedResults<Message>
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var messages: Messages
    @EnvironmentObject var userInformation: UserInformation
    @EnvironmentObject var googleDelegate: GoogleDelegate
    @State var isCurrentUserLoadServer: Bool = true
    @State var isPresentingTermsPopUp = false

    var body: some View {
        Button(action: {
            isPresentingTermsPopUp = true
        }){
            VStack {
                Text("f")
                    .font(.custom(fontStyle, size: 30))
                    .foregroundColor(Color(UIColor.white))
                    .background(
                        Circle()
                            .fill(convertHextoRGB(hexColor: "3B5998"))
                            .frame(width: CGFloat(36), height: CGFloat(36))
                            .shadow(color: Color(UIColor.black).opacity(0.06), radius: 4, x: 3, y: 3)
                    )
                        .padding([.trailing], (width ?? CGFloat(100))*0.06)
            }
        }
        .actionSheet(isPresented: $isPresentingTermsPopUp, content: {
            ActionSheet(title: Text("Terms of Use"), message: Text("By clicking continue you are agree to terms of use (EULA)."), buttons: [.destructive(Text("Terms of Use"), action: {
                Utilities.openLink(urlString: links.termsOfUse)
            }),
            .default(Text("Continue"), action: {
                self.loginFB(completion: { id in
                    // Load messages from server
                    NetworkStatus.checkNetworkStatus(completion: { netStat in
                        if netStat["status"] == true {
                            DispatchQueue.main.async {
                                // Update messages
                                self.updateMessageHistoryServer(userID: id)
                                self.isHiddenLoginView = true
                                self.isHiddenChatView = false
                            }
                        }
                    })
                })
            }),
            .cancel(Text("Cancel"))])
        })
    }
    
    //Scenerio
    //First check if agent is already created-> If created -> just login
    // If agent is not created-> hit create_agent endpoint and create new agent

    func loginFB(completion: @escaping(String) -> Void) {
        var email: String = ""
        var givenName: String = ""
        var familyName: String = ""
        var fbUserInformation: [String: String] = [String: String]()

        let fbLoginManager: LoginManager = LoginManager()
        fbLoginManager.logOut()
        fbLoginManager.logIn(permissions: ["email"], from: UIApplication.shared.windows.last?.rootViewController) { (result, error) -> Void in

            // Handeler FB Login
            if let fbAccessToken = result!.token {
                let id: String = fbAccessToken.userID
                // Get user profile infromation
                let tokenString: String = fbAccessToken.tokenString    // Set FBGraphAPI token
                let request = FBSDKLoginKit.GraphRequest(               // Make FBGraphAPI request object
                    graphPath: "me",
                    parameters: ["fields": "email, name"],              // Specify data request from Facebook Graph API "User" Root Node
                    tokenString: tokenString,
                    version: nil,
                    httpMethod: .get
                )

                request.start(completionHandler: {connection, result, error in  // Send FBGraphAPI Request

                    // Handeler for request
                    if let userProfile = result as? [String: String] {
                        // Set email
                        email = userProfile["email"]!
                        // Set names
                        let fullName = userProfile["name"]
                        let names: [String] = fullName!.components(separatedBy: " ")
                        let namesNum: Int = names.count
                        switch namesNum {
                            case 2:
                                givenName = names[0]
                                familyName = names[1]
                            case 3:
                                givenName = names[0]
                                familyName = names[2]
                            default:
                                givenName = ""
                                familyName = ""
                                print("Error no name recieved")
                        }

                        fbUserInformation = BytePalAuth.facebookLogin(
                                                                id: id,
                                                                email: email,
                                                                givenName: givenName,
                                                            familyName: familyName)

                        // Saved userID if it exists
                        if fbUserInformation["id"]! != "" {
                            
                            // Check IAP Subscription
                            IAPManager.shared.initIAP(userID: fbUserInformation["id"]!)
                            
                            // Create Agent
                            self.createAgent(id: fbUserInformation["id"]!)

                            // Save user information to cache
                            if UserInformationCoreDataRead.count == 0 {
                                // Is not logged in
                                
                                let userInformationCoreDataWrite: User = User(context: self.moc)
                                userInformationCoreDataWrite.id = fbUserInformation["id"]!
                                userInformationCoreDataWrite.email = fbUserInformation["email"]!
                                userInformationCoreDataWrite.givenName = fbUserInformation["givenName"]!
                                userInformationCoreDataWrite.familyName = fbUserInformation["familyName"]!
                                DispatchQueue.main.async {
                                    try? self.moc.save()
                                }
                            } else if UserInformationCoreDataRead.count > 0 && UserInformationCoreDataRead[0].isLoggedIn == false {
                                // Is logged (After termination)
                                
                                for userInformation in UserInformationCoreDataRead {
                                    moc.delete(userInformation)
                                }
                                
                                let userInformationCoreDataWrite: User = User(context: self.moc)
                                userInformationCoreDataWrite.id = fbUserInformation["id"]!
                                userInformationCoreDataWrite.email = fbUserInformation["email"]!
                                userInformationCoreDataWrite.givenName = fbUserInformation["givenName"]!
                                userInformationCoreDataWrite.familyName = fbUserInformation["familyName"]!
                                
                                DispatchQueue.main.async {
                                    try? self.moc.save()
                                }
                            }
                            
                            

                            // Write user information to RAM
                            self.userInformation.id = fbUserInformation["id"]!
                            self.userInformation.email = fbUserInformation["email"]!
                            self.userInformation.givenName = fbUserInformation["givenName"]!
                            self.userInformation.familyName = fbUserInformation["familyName"]!
                            self.userInformation.fullName = fbUserInformation["givenName"]! + " " + fbUserInformation["familyName"]!

                            completion(fbUserInformation["id"]!)
                        }
                    }
                })
            }
        }
    }

    func createAgent(id: String) {
        try? APIViewModel.shared.create_agent(user_id: id, onSuccess: {
            DispatchQueue.main.async {
                self.isHiddenLoginView = true
            }
        }, onFailure: { (error) in
            print(error)
        })
    }

    func updateMessageHistoryServer(userID: String) {
        // Clear message cache
        for message in MessagesCoreDataRead {
            moc.delete(message)
        }
        try? self.moc.save()
        
        // Get messages from server
        guard let history = self.messages.getHistory(userID: userID) else {
            return
        }
        
        // Load messages
        for message in history {
            self.loadMessageServer(message: message)
        }
    }

    func loadMessageServer(message: [String: String]) {
        // Load messages into RAM
        let isCurrentUser = (message["type"] as? String) == "bot" ? false : true
        if let text = message["text"] {
                self.messages.list.insert(["id": UUID(), "content": text, "isCurrentUser": isCurrentUser], at: self.messages.list.startIndex)
        }

        //  Toggle the user type
        isCurrentUserLoadServer.toggle()
    }

}
