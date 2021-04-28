//
//  SignupView.swift
//  BytePal AI, LLC
//
//  Created by Scott Hom on 7/17/20.
//  Copyright © 2020 BytePal AI, LLC. All rights reserved.
//

import SwiftUI
import CoreData

struct SignupView: View {
    
    // Arguments
    
    var width: CGFloat?
    var height: CGFloat?
    
    // Control which view is being shown
    @Binding var isHiddenLoginView: Bool
    @Binding var isHiddenChatView: Bool
    @Binding var isHiddenSignupView: Bool
    
    // BytePal Objects
    
    // Core Data
    var container: NSPersistentContainer!
    
    @FetchRequest(entity: User.entity(), sortDescriptors: []) var UserInformationCoreDataRead: FetchedResults<User>
    @Environment(\.managedObjectContext) var moc
    
    // Environment Object
    @EnvironmentObject var userInformation: UserInformation
    @EnvironmentObject var messages: Messages
    @EnvironmentObject var googleDelegate: GoogleDelegate
    //    @ObservedObject var keyboard = KeyboardResponder()
    
    // Observable Objects
    
    // States
    
    //// Text  field states
    @State var email: String = ""
    @State var givenName: String = ""
    @State var familyName: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    
    //// Control which view is being shown
    @State var isShowingSignupError: Bool = false
    @State var signupError: String = ""
    @State var isShowingChatView: Bool = false
    @State var isPresentingTermsPopUp: Bool = false
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            // Back button
            Button (
                action: {
                    self.isHiddenLoginView = false
                    self.isHiddenSignupView = true
                },
                label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color(UIColor.systemBlue))
                            .font(title2Custom)
                        Text("Back")
                            .foregroundColor(Color(UIColor.systemBlue))
                            .font(title2Custom)
                    }
                }
            )
            .padding()
            //                .isHidden(keyboard.isUp, remove: keyboard.isUp)
            
            // Main signup view
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    
                    
                    VStack(spacing: 30){
                        Text("I am full of thoughts to share with you")
                            .foregroundColor(.appFontColorBlack)
                            .font(.largeTitle)
                            .fontWeight(.regular)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding()
                        //                            .isHidden(keyboard.isUp, remove: keyboard.isUp)
                        
                        ZStack {
                            TransparentRoundedBackgroundView(cornerRadius: 15)
                            VStack(alignment: .leading) {
                                Text("Email")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.appFontColorBlack)
                                TextField("Enter email", text: $email)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            .padding()
                        }
                        .frame(height: 75, alignment: .center)
                        ZStack {
                            TransparentRoundedBackgroundView(cornerRadius: 15)
                            VStack(alignment: .leading) {
                                Text("First Name")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.appFontColorBlack)
                                TextField("Enter first name", text: $givenName)
                                    .disableAutocorrection(true)
                            }
                            .padding()
                        }
                        .frame(height: 75, alignment: .center)
                        ZStack {
                            TransparentRoundedBackgroundView(cornerRadius: 15)
                            VStack(alignment: .leading) {
                                Text("Last Name")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.appFontColorBlack)
                                TextField("Enter last name", text: $familyName)
                                    .disableAutocorrection(true)
                            }
                            .padding()
                        }
                        .frame(height: 75, alignment: .center)
                        ZStack {
                            TransparentRoundedBackgroundView(cornerRadius: 15)
                            VStack(alignment: .leading) {
                                Text("Password")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.appFontColorBlack)
                                SecureField("Enter password", text: $password)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            .padding()
                        }
                        .frame(height: 75, alignment: .center)
                        ZStack {
                            TransparentRoundedBackgroundView(cornerRadius: 15)
                            VStack(alignment: .leading) {
                                Text("Confirm Password")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.appFontColorBlack)
                                SecureField("Enter password", text: $confirmPassword)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            .padding()
                        }
                        .frame(height: 75, alignment: .center)
                    }
                    .padding()
                    
                    // Signup button (seperaete from main signup part to center the button)
                    ////  button centering logic is done using the alignmenet guide modifier on the VStack
                    HStack(alignment: .center) {
                        Button(action: {
                        }) {
                            Text("")
                        }
                        .actionSheet(isPresented: $isPresentingTermsPopUp, content: {
                            ActionSheet(title: Text("Terms of Use"), message: Text("By clicking continue you are agree to terms of use (EULA)."), buttons: [.destructive(Text("Terms of Use"), action: {
                                self.openTerms()
                            }),
                            .default(Text("Continue"), action: {
                                self.signup()
                            }),
                            .cancel(Text("Cancel"))])
                        })
                        Button(action: {
                            if self.email != "" && self.givenName != "" && self.familyName != "" && self.password != "" {
                                if self.password == self.confirmPassword {
                                    self.isPresentingTermsPopUp = true
                                } else {
                                    self.signupError = "Password does not match"
                                    isShowingSignupError = true
                                }
                            }
                            else {
                                self.signupError = "Error missing signup field"
                                isShowingSignupError = true
                            }
                        }, label: {
                            Text("Signup")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        })
                        .alert(isPresented: $isShowingSignupError, content: {
                            Alert(title: Text("Error"), message: Text(self.signupError), dismissButton: .default(Text("OK")))
                        })
                        .frame(width: 250, height: 60, alignment: .center)
                        .background(Color.appGreen)
                        .cornerRadius(8, antialiased: true)
                        .shadow(radius: 50)
                        .animation(.easeIn)
                        .padding(.top, 60)
                        .position(x: UIScreen.main.bounds.width/2)
                    }
//                    .alignmentGuide(.leading, computeValue: { _ in ( -((width ?? 200) - (width ?? 200)*0.70)/2)})
                }
                
            }
        }
        .background(
            
            // Make background have a green linear gradiate
            LinearGradient(
                gradient: Gradient(
                    colors:
                        [
                            Color.appLightGreen,
                            Color.appGreen
                        ]
                ),
                startPoint: .topLeading,
                endPoint: .leading
            )
            .blur(radius: 400)
            .edgesIgnoringSafeArea(.all)
            
        )
        .frame(width: self.width, height: self.height)
        
    }
    
    func openTerms() {
        Utilities.openLink(urlString: links.termsOfUse)
    }
    // Make a request to server /signup endpoiunt
    func signup () {
        try? APIViewModel.shared.register(first_name: self.givenName, last_name: self.familyName, email: self.email, password: self.password, onSuccess: { user_id in
            self.checkAgentWith(user_id)
        }, onFailure: { (error) in
            if error == "already_exist" {
                self.signupError = "User is already signed up"
            }
        })
        
    }
    
    // Make a request to server /create_agent endpoiunt
    func checkAgentWith(_ userID: String) {
        try? APIViewModel.shared.create_agent(user_id: userID) {
            IAPManager.shared.initIAP(userID: userID)
            // Save user information to cache
            if UserInformationCoreDataRead.count == 0 {
                // Is not logged in
                let userInformationCoreDataWrite: User = User(context: self.moc)
                userInformationCoreDataWrite.id = userID
                userInformationCoreDataWrite.email = self.email
                userInformationCoreDataWrite.givenName = self.givenName
                userInformationCoreDataWrite.familyName = self.familyName
                DispatchQueue.main.async {
                    try? self.moc.save()
                }
            } else if UserInformationCoreDataRead.count > 0 && UserInformationCoreDataRead[0].isLoggedIn == false {
                // Is logged (After termination)
                for userInformation in UserInformationCoreDataRead {
                    moc.delete(userInformation)
                }
                let userInformationCoreDataWrite: User = User(context: self.moc)
                userInformationCoreDataWrite.id = userID
                userInformationCoreDataWrite.email = self.email
                userInformationCoreDataWrite.givenName = self.givenName
                userInformationCoreDataWrite.familyName = self.familyName
                DispatchQueue.main.async {
                    try? self.moc.save()
                }
            }
            
            // Write user information to RAM
            DispatchQueue.main.async {
                self.userInformation.id = userID
                self.userInformation.email = self.email
                self.userInformation.givenName = self.givenName
                self.userInformation.familyName = self.familyName
                self.userInformation.fullName = self.givenName + " " + self.familyName
                
                self.isShowingSignupError = false
                self.isHiddenLoginView = true
                self.isHiddenSignupView = true
                self.isHiddenChatView = false
            }
        } onFailure: { (error) in
            print("------- Agent ALREADY created")
        }
        
    }
    
}
