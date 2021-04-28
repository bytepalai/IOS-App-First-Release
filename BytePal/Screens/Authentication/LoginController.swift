//
//  LoginController.swift
//  BytePal
//
//  Created by Scott Hom on 8/4/20.
//  Copyright © 2020 BytePal-AI. All rights reserved.
//

import Foundation
import SwiftUI
import FBSDKLoginKit
import GoogleSignIn

class BytePalAuth {
    
    
    static func login (email: String, password: String, userID: @escaping (String) -> Void) {
//      Init
        let semaphore = DispatchSemaphore (value: 0) //Create counter for async management
        var loginStatus: String = ""

//      Define header of POST Request
        var request = URLRequest(url: URL(string: "\(API_HOSTNAME)/login")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
//      Define body POST Request
        let parameters = "{  \n   \"email\":\"\(email)\",\n   \"password\":\"\(password)\"\n}"
        let postData = parameters.data(using: .utf8)
        request.httpBody = postData
        
        // Define JSON response format
        struct responseStruct: Decodable {
            var user_id: String
        }
        
//      Create Post Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//          Handle Response
            guard let data = data else {
                print(String(describing: error))
                loginStatus = ""
                return
            }
            do {
                if String(data: data, encoding: .utf8)! == "Wrong Password" {
                    loginStatus = "Wrong email or password"
                } else {
                    // Set user_id
                    let reponseObject = try JSONDecoder().decode(responseStruct.self, from: data)
                    let user_id: String = reponseObject.user_id
                    loginStatus = user_id
                    UserDefaults.standard.setValue(email, forKey: "user_email")
                    Self.createAgent(user_id)
                }
            } catch {
                print(error)
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        
//      Return loginStatus
        userID(loginStatus)
    }
    
    static func createAgent(_ user_id: String) {
        try? APIViewModel.shared.create_agent(user_id: user_id) {
            UserDefaults.standard.setValue(user_id, forKey: "user_id")
        } onFailure: { (error) in
            print(error)
        }
    }
    
    static func facebookLogin (id: String, email: String, givenName: String, familyName: String) -> [String: String] {
        
            // Init
            let semaphore = DispatchSemaphore (value: 0) //Create counter for async management
            var loginStatus: String = ""
            var userInformation: [String: String] = [String: String]()
        
            // Set email and name
            userInformation["email"] = email
            userInformation["givenName"] = givenName
            userInformation["familyName"] = familyName

            // Define header of POST Request
            var request = URLRequest(url: URL(string: "\(API_HOSTNAME)/facebook")!,timeoutInterval: Double.infinity)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"

            // Define body POST Request
            let parameters = """
            {
                \"id\": \"\(id)\",
                \"email\": \"\(email)\",
                \"givenName\": \"\(givenName)\",
                \"familyName\": \"\(familyName)\"
            }
            """

            let postData = parameters.data(using: .utf8)
            request.httpBody = postData

            // Define JSON response format
            struct responseStruct: Decodable {
                var user_id: String
            }

            // Create Post Request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // Handle Response
                guard let data = data else {
                    print(String(describing: error))
                    loginStatus = ""
                    return
                }
                do {
                    let reponseObject = try JSONDecoder().decode(responseStruct.self, from: data)
                    let user_id: String = reponseObject.user_id
                    loginStatus = user_id
                } catch {
                    print(error)
                }
                semaphore.signal()
            }
            task.resume()
            semaphore.wait()
        
            // Set BytePal User ID
            userInformation["id"] = loginStatus
        
            // Return loginStatus
            return userInformation
    }
    
    static func googleLogin (id: String, email: String, givenName: String, familyName: String, onSuccess: @escaping ((_ user_id: String) -> Void), onFailure: @escaping ((_ error: String) -> Void)) {
    //      Init
            let semaphore = DispatchSemaphore (value: 0) //Create counter for async management

    //      Define header of POST Request
            var request = URLRequest(url: URL(string: "\(API_HOSTNAME)/google")!,timeoutInterval: Double.infinity)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"

    //      Define body POST Request
        
            let parameters = """
            {
                \"idToken\": \"\(id)\",
                \"email\": \"\(email)\",
                \"givenName\": \"\(givenName)\",
                \"familyName\": \"\(familyName)\"
            }
            """
            
            let postData = parameters.data(using: .utf8)
            request.httpBody = postData

            // Define JSON response format
            struct responseStruct: Decodable {
                var user_id: String
            }
        
    //      Create Post Request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
    //          Handle Response
                guard let data = data else {
                    print(String(describing: error))
                    onFailure(error?.localizedDescription ?? "")
                    return
                }
                do {
                    let reponseObject = try JSONDecoder().decode(responseStruct.self, from: data)
                    let user_id: String = reponseObject.user_id
                    UserDefaults.standard.setValue(user_id, forKey: "user_id")
                    onSuccess(user_id)
                } catch {
                    print(error)
                    onFailure(error.localizedDescription)
                }
                semaphore.signal()
            }
        
            task.resume()
            semaphore.wait()

            // Pass loginStatus to handler
        }
}

class SocialMediaAuth {
    func fbLogout() {
        let fbLoginManager: LoginManager = LoginManager()
        fbLoginManager.logOut()
    }
    
    func GoogleLogout() {
        print("--------- sign out Google")
        GIDSignIn.sharedInstance()?.signOut()
    }
    
    func personalLogout() {
        print("------ Personal Logout")
    }
    
    func logout(personalLoginStatus: Bool) {
        let account: String = self.getAccountLoginStatus(personalLoginStatus: personalLoginStatus)
        switch account {
            case "Facebook":
                print("----- Logged out of Facebook")
                self.fbLogout()
            case "Google":
                print("----- Logged out of Google")
                self.GoogleLogout()
            case "Personal":
                print("----- Logged out of Personal")
                self.personalLogout()
            default:
                print("----- Error: Account did not logout succesfully")
        }
    }
    
    func getAccountLoginStatus(personalLoginStatus: Bool) -> String {
        
        if(GIDSignIn.sharedInstance()?.currentUser != nil){
            print("---- Google")
            return "Google"
        } else if (AccessToken.current ?? nil) != nil {
            if !AccessToken.current!.isExpired {
                print("---- Facebook")
                return "Facebook"
            }
        } else if personalLoginStatus {
            print("---- Personal")
            return "Personal"
        } else {
            print("---- Logged Out")
            return "logged out"
        }
        print("---- Error 2")
        return "logged out"
    }
}

class FBLogin: ObservableObject {
    @Published var isShowingChatView: Bool = false
}

protocol google_login_delegate {
    func loginSuccessFull(userID: String)
}

class GoogleDelegate: NSObject, GIDSignInDelegate, ObservableObject {
    
    let bytepalAuth: BytePalAuth = BytePalAuth()
    @Published var userID: String = ""
    @Published var email: String = ""
    @Published var givenName: String = ""
    @Published var familyName: String = ""
    @Published var signedIn: Bool = false
    var delegate: google_login_delegate?
    
    // Signin Handeler
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)  {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        
        let clientID: String =  GIDSignIn.sharedInstance()?.currentUser.userID ?? user.authentication.idToken
        let email: String = GIDSignIn.sharedInstance().currentUser!.profile.email
        let givenName: String = GIDSignIn.sharedInstance().currentUser!.profile.givenName
        let familyName: String = GIDSignIn.sharedInstance().currentUser!.profile.familyName
        
        
        BytePalAuth.googleLogin(id: clientID, email: email, givenName: givenName, familyName: familyName) { (userID) in
            DispatchQueue.main.async {
                self.userID = userID
                self.email = email
                self.givenName = givenName
                self.familyName = familyName
                UserDefaults.standard.setValue(email, forKey: "user_email")
                UserDefaults.standard.setValue(userID, forKey: "user_id")
                self.createAgent(userID)
                self.delegate?.loginSuccessFull(userID: userID)
            }
        } onFailure: { (e) in
            print(e)
        }
    }
    
    func createAgent(_ user_id: String) {
        try? APIViewModel.shared.create_agent(user_id: user_id) {
            DispatchQueue.main.async {
                self.signedIn = true
            }
        } onFailure: { (error) in
            print(error)
        }
    }
    
    // Signout Handeler
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        self.signedIn = false
    }
}
