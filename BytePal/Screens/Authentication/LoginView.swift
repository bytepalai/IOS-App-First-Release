//
//  LoginView.swift
//  SwiftUIChatMessage
//
//  Created by Scott Hom on 6/28/20.
//  Copyright © 2020 BytePal-AI. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit

struct LoginView: View {
    // Controller both views
    @State var isHiddenLoginView: Bool = false
    @State var isHiddenSignupView: Bool = true
    @State var isHiddenChatView: Bool = true
    
    // Self defined object
    var socialMediaAuth: SocialMediaAuth = SocialMediaAuth()
    var messageHistoryData: [[String: String]] = [[String: String]]()
    // Core Data
    var container: NSPersistentContainer!
    @FetchRequest(entity: Message.entity(), sortDescriptors: []) var MessagesCoreDataRead: FetchedResults<Message>
    @FetchRequest(entity: User.entity(), sortDescriptors: []) var UserInformationCoreDataRead: FetchedResults<User>
    @Environment(\.managedObjectContext) var moc
    
    // Environment Object
    @EnvironmentObject var messages: Messages
    @EnvironmentObject var userInformation: UserInformation
    @EnvironmentObject var googleDelegate: GoogleDelegate
    
    // States
    @State var isCurrentUserLoadServer: Bool = true
    @State var TextForMultiLine: String =
        """
        """
    @State var email: String = ""
    @State var password: String = ""
    @State var loginResp: String = ""
    @State var loginError: String = ""
    @State var isPresentingTermsPopUp = false
    // Signup (Hidden View, initial state)
    private let cornerRadious: CGFloat = 8
    private let buttonHeight: CGFloat = 60
    let cornerRadiusTextField: CGFloat = 15.0
    let viewHeightTextField: CGFloat = 75
    let mainViewSpacing: CGFloat = 60
    let textFieldSpace: CGFloat = 30
    let backgroundBlurRadious: CGFloat = 400
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    LargeLogo(
                        width: geometry.size.width,
                        height: geometry.size.height - 70
                    )
                    Text(loginError)
                        .foregroundColor(Color(UIColor.systemRed))
                        .font(.custom(fontStyle, size: 18))
                    TextField("Enter email", text: $email)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding([.leading, .trailing], 24)
                        .padding([.top], 12)
                    SecureField("Enter password", text: $password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding([.leading, .trailing], 24)
                        .padding([.top], 32)
                    Button(action: {
                        Utilities.openLink(urlString: links.termsOfUse)
                    }) {
                        Text("Terms of use").font(.footnote)
                            .foregroundColor(.gray)
                            .underline()
                    }
                    .padding([.top], 16)
                    
                    Button(action: {
                        isPresentingTermsPopUp = true
                    }){
                        LoginButtonView(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                    }
                    .padding([.top], 16)
                    .actionSheet(isPresented: $isPresentingTermsPopUp, content: {
                        ActionSheet(title: Text("Terms of Use"), message: Text("By clicking continue you are agree to terms of use (EULA)."), buttons: [.destructive(Text("Terms of Use"), action: {
                            Utilities.openLink(urlString: links.termsOfUse)
                        }),
                        .default(Text("Continue"), action: {
                            self.personalLogin(email: self.email, password: self.password)
                        }),
                        .cancel(Text("Cancel"))])
                    })
                    DividerCustom(
                        color: Color(UIColor.lightGray).opacity(0.60),
                        length: Float(geometry.size.width)*(7/10),
                        width: 1
                    )
                    SignupBar(
                        width: geometry.size.width,
                        height: geometry.size.width,
                        isHiddenLoginView: self.$isHiddenLoginView,
                        isHiddenChatView: self.$isHiddenChatView,
                        isHiddenSignupView: self.$isHiddenSignupView
                    )
                    .padding(.top, 20)
                }
                .onAppear(perform: {
                    self.googleDelegate.delegate = self
                    self.onAppearLoginView()
                })
                .isHidden(self.isHiddenLoginView, remove: isHiddenLoginView)
                .zIndex(2)
                // Signup View
                SignupView(
                    width: geometry.size.width,
                    height: geometry.size.height,
                    isHiddenLoginView: self.$isHiddenLoginView,
                    isHiddenChatView: self.$isHiddenChatView,
                    isHiddenSignupView: self.$isHiddenSignupView
                )
                .isHidden(self.isHiddenSignupView, remove: self.isHiddenSignupView)
                .zIndex(1)
                
                // Chat View
                ChatView(
                    width: geometry.size.width,
                    height: geometry.size.height,
                    isHiddenLoginView: self.$isHiddenLoginView
                )
                .isHidden(self.isHiddenChatView, remove: self.isHiddenChatView)
                .zIndex(0)
            }
        }
    }
            
    func onAppearLoginView() {
        print("------ Login View State: \(self.isHiddenLoginView)")
        // Go to Chat View
        if UserDefaults.standard.bool(forKey: "is_login") {
            for userInfo in self.UserInformationCoreDataRead {
                self.userInformation.id = userInfo.id ?? "Error: ID not unwrapped succesfully onAppearLoginView()"
                self.userInformation.email = userInfo.email ?? ""
                self.userInformation.givenName = userInfo.givenName ?? ""
                self.userInformation.familyName = userInfo.familyName ?? ""
                self.userInformation.fullName =  (userInfo.givenName ?? "") + " " + (userInfo.familyName ?? "")
            }
            guard let id = UserDefaults.standard.string(forKey: "user_id") else {return}
            DispatchQueue.main.async {
                self.gotoDashboard(id)
            }
            return
        }
        
        // Set values on first application launch
        if UIApplication.isFirstLaunch() {
            let userInformationCoreDataWrite: User = User(context: self.moc)
            userInformationCoreDataWrite.isLoggedIn = false
            try? self.moc.save()
        } else {
            // Load messages from cache if there is network connection
            NetworkStatus.checkNetworkStatus(completion: {netStat in
                let isNotConnected: Bool = !netStat["status"]!
                
                if isNotConnected {
                    print("Loading messages from cache ...")
                    var messageNumber: Int = 0
                    if self.MessagesCoreDataRead.isEmpty != true {
                        for message in self.MessagesCoreDataRead {
                            self.loadMessageHistoryCache(message: message)
                            messageNumber += 1
                        }
                    }
                }
            })
            // Load user information from cache
        }
    }
    
    func personalLogin (email: String, password: String) {
        // Init login status
        try? APIViewModel.shared.login(email: email, password: password) { user_id in
            self.checkAgentWith(user_id)
        } onFailure: { (error) in
            if error == "invalid_credentials" {
                self.loginError = "Wrong email or password"
            }
        }
    }
    
    func checkAgentWith(_ user_id: String) {
        
        try? APIViewModel.shared.create_agent(user_id: user_id) {
            DispatchQueue.main.async {
                self.gotoDashboard(user_id)
            }
        } onFailure: { (e) in
            print(e)
        }
        
    }
    
    func gotoDashboard(_ user_id: String) {
        // Check IAP Subscription
        IAPManager.shared.initIAP(userID: user_id)
        // Save user information to cache
        if UserInformationCoreDataRead.count == 0 {
            // Is not logged in
            let userInformationCoreDataWrite: User = User(context: self.moc)
            userInformationCoreDataWrite.isLoggedIn = true
            userInformationCoreDataWrite.id = user_id
            userInformationCoreDataWrite.email = email
            DispatchQueue.main.async {
                try? self.moc.save()
            }
        } else if UserInformationCoreDataRead.count > 0 && UserInformationCoreDataRead[0].isLoggedIn == false {
            // Is logged (After termination)
            for userInformation in UserInformationCoreDataRead {
                moc.delete(userInformation)
            }
            let userInformationCoreDataWrite: User = User(context: self.moc)
            userInformationCoreDataWrite.isLoggedIn = true
            userInformationCoreDataWrite.id = user_id
            userInformationCoreDataWrite.email = email
            DispatchQueue.main.async {
                try? self.moc.save()
            }
        }
        // Save user information to RAM
        DispatchQueue.main.async {
            self.userInformation.isLoggedIn = true
            self.userInformation.id = user_id
            self.userInformation.email = self.email
        }
        // if connected to a network, load messages from server.
        NetworkStatus.checkNetworkStatus(completion: { netStat in
            if netStat["status"] == true {
                print("Loading messages from server ...")
                DispatchQueue.main.async {
                    // Update messages
                    self.updateMessageHistoryServer(userID: user_id)
                }
            }
        })
        // Clear LoginView states
        self.email = ""
        self.password = ""
        self.loginResp = ""
        self.loginError = ""
        DispatchQueue.main.async {
            self.isHiddenLoginView = true
            self.isHiddenSignupView = true
            self.isHiddenChatView = false
        }
        // Go to chat view
    }
    
    func loadMessageHistoryCache(message: Message) {
        if message.id != nil {
                self.messages.list.insert(["id": message.id ?? "", "content": message.content ?? "", "isCurrentUser": message.isCurrentUser], at: self.messages.list.startIndex)
        } else {
            print("-------- Error: Unable to unwrap message ID. message = \(message) for /BytePal/Screens/Authentication/LoginView.swift")
        }
    }
    
    func updateMessageHistoryServer(userID: String) {
        print("----------- load SERVER(LOGIN VIEW)")
        // Clear message cache
        for message in MessagesCoreDataRead {
            moc.delete(message)
        }
        try? self.moc.save()
        // Get messages from server
        guard let history = self.messages.getHistory(userID: userID) else {return}
        // Load messages
        for message in history {
            self.loadMessageServer(message: message)
        }
    }
    
    func loadMessageServer(message: [String: String]) {
        // Load messages into RAM
        let isCurrentUser = (message["type"] as? String) == "bot" ? false : true
            self.messages.list.insert(["id": UUID(), "content": message["text"] ?? "Error can't unwrap message text", "isCurrentUser": isCurrentUser], at: self.messages.list.startIndex)
        //  Toggle the user type
        isCurrentUserLoadServer.toggle()
    }
    
}

extension LoginView: google_login_delegate {
    func loginSuccessFull(userID: String) {
        DispatchQueue.main.async {
            self.gotoDashboard(userID)
        }
    }
}
