//
//  ViewControllerViewModel.swift
//  CargoLine
//
//  Created by Zain
//  Copyright © 2020 ZeeTech. All rights reserved.
//

import Foundation

class APIViewModel: NSObject {
    static let shared = APIViewModel()
    
    private override init() {
    }
    /// ErrorHandling Experiment in first time.
    enum LoginErrors: Error {
        case invalidResponse
        case failToParse
        case invalidDowncasting
        case invalid_credentials
    }
    /**
     This method will call login api,download user data into Model.
     It has two Clousers will be called in Controller.
     - Parameter email: The User email in String formate.
     - Parameter password: Password entered by user in string formate.
     - Parameter onSuccess: If everything goes right.
     - Parameter onFailure: In case of any error.
     - Returns: Nothing.
     */
    func login(email: String, password: String, onSuccess: @escaping (_ userID: String) -> Void, onFailure: @escaping (_ error: String) -> Void) throws {
        UserDefaults.standard.setValue(email, forKey: "user_email")
        MoyaApiManager.shared.provider.request(.login(email: email, password: password)) { (result) in
            switch result {
                
            case let .success(moyaResponse):
                let statusCode = moyaResponse.statusCode
                switch statusCode {
                case 200:
                    do {
                        guard let response = try moyaResponse.mapJSON() as? [String:Any] else {return}
                        print(response)
                        guard let id = response["user_id"] as? String else {return}
                        UserDefaults.standard.setValue(id, forKey: "user_id")
                        UserDefaults.standard.setValue(true, forKey: "is_login")
                        onSuccess(id)
                    } catch {
                        onFailure("invalid_credentials")
                    }
                default:
                    do {
                      //  let dic = try! moyaResponse.mapJSON()
                    //    print(dic)
                        let _ = try moyaResponse.mapString()
                        onFailure("invalid_credentials")
                    } catch {
                        onFailure("Something went wrong")
                    }
                }
            case let .failure(error):
                print(error.errorDescription ?? "Error")
                onFailure("No Internet")
            }
        }
    }
    /**
     This method will call register api.
     It has two Clousers will be called in Controller.
     - Parameter email: The User email in String formate.
     - Parameter password: Password entered by user in string formate.
     - Parameter first_name: First name of user in string formate.
     - Parameter last_name: Last name of user in string formate.
     - Parameter onSuccess: If everything goes right.
     - Parameter onFailure: In case of any error.
     - Returns: Nothing.
     */
    func register(first_name: String, last_name: String, email: String, password: String, onSuccess: @escaping (_ user_id: String) -> Void, onFailure: @escaping (_ error: String) -> Void) throws {
        UserDefaults.standard.setValue(email, forKey: "user_email")
        MoyaApiManager.shared.provider.request(.register(first_name: first_name, last_name: last_name, email: email, password: password)) { (result) in
            switch result {
                
            case let .success(moyaResponse):
                let statusCode = moyaResponse.statusCode
                switch statusCode {
                case 200:
                    do {
                        guard let response = try moyaResponse.mapJSON() as? [String:Any] else {return}
                        print(response)
                        guard let id = response["user_id"] as? String else {return}
                        UserDefaults.standard.setValue(id, forKey: "user_id")
                        onSuccess(id)
                    } catch {
                        onFailure("already_exist")
                    }
                default:
                    do {
                        let _ = try moyaResponse.mapString()
                        onFailure("already_exist")
                    } catch {
                        onFailure("Something went wrong")
                    }
                }
            case let .failure(error):
                print(error.errorDescription ?? "Error")
                onFailure("No Internet")
            }
        }
    }
    /**
     This method will call create_agent api,
     It has two Clousers will be called in Controller.
     - Parameter user_id: The User id of the user in String formate.
     - Parameter onSuccess: If everything goes right.
     - Parameter onFailure: In case of any error.
     - Returns: Nothing.
     */
    func create_agent(user_id: String, onSuccess: @escaping () -> Void, onFailure: @escaping (_ error: String) -> Void) throws {
        MoyaApiManager.shared.provider.request(.create_agent(user_id: user_id)) { (result) in
            switch result {
                
            case let .success(moyaResponse):
                let statusCode = moyaResponse.statusCode
                switch statusCode {
                case 200:
                    do {
                        let response = try moyaResponse.mapString()
                        print(response)
                        UserDefaults.standard.setValue(true, forKey: "is_login")
                        onSuccess()
                    } catch {
                        onFailure("Something went wrong")
                    }
                default:
                    do {
                      //  let dic = try! moyaResponse.mapJSON()
                    //    print(dic)
                        guard let dict: [String: Any] = try moyaResponse.mapJSON() as? [String: Any] else {throw LoginErrors.invalidResponse}
                        guard let message = dict["status_message"] else {throw LoginErrors.invalidResponse}
                        onFailure(message as? String ?? "No Value")
                    } catch {
                        onFailure("Something went wrong")
                    }
                }
            case let .failure(error):
                print(error.errorDescription ?? "Error")
                onFailure("No Internet")
            }
        }
    }
    /**
     This method will call register api.
     It has two Clousers will be called in Controller.
     - Parameter user_id: The UserID of user  in String formate.
     - Parameter text: Message text  entered by user in string formate.
     - Parameter onSuccess: If everything goes right.
     - Parameter onFailure: In case of any error.
     - Returns: Nothing.
     */
    func sendMessage(text: String, type: String, onSuccess: @escaping () -> Void, onFailure: @escaping (_ error: String) -> Void) {
        let id = UserDefaults.standard.string(forKey: "user_id") ?? ""
        
        MoyaApiManager.shared.provider.request(.interact(user_id: id, text: text, type: type)) { (result) in
            switch result {
                
            case let .success(moyaResponse):
                let statusCode = moyaResponse.statusCode
                switch statusCode {
                case 200:
                   onSuccess()
                default:
                    do {
                      //  let dic = try! moyaResponse.mapJSON()
                    //    print(dic)
                        guard let dict: [String: Any] = try moyaResponse.mapJSON() as? [String: Any] else {
                            onFailure("Failed to parse")
                            return
                        }
                        guard let message = dict["status_message"] else {
                            onFailure("Failed to parse")
                            return
                        }
                        onFailure(message as? String ?? "No Value")
                    } catch {
                        onFailure("Something went wrong")
                    }
                }
            case let .failure(error):
                print(error.errorDescription ?? "Error")
                onFailure("No Internet")
            }
        }
    }
    /**
     This method will call register api.
     It has two Clousers will be called in Controller.
     - Parameter user_id: The UserID of user  in String formate.
     - Parameter text: Message text  entered by user in string formate.
     - Parameter onSuccess: If everything goes right.
     - Parameter onFailure: In case of any error.
     - Returns: Nothing.
     */
    func historyMessage(onSuccess: @escaping () -> Void, onFailure: @escaping (_ error: String) -> Void) {
        let id = UserDefaults.standard.string(forKey: "user_id") ?? ""
        
        MoyaApiManager.shared.provider.request(.history(user_id: id)) { (result) in
            switch result {
                
            case let .success(moyaResponse):
                let statusCode = moyaResponse.statusCode
                switch statusCode {
                case 200:
                   onSuccess()
                default:
                    do {
                      //  let dic = try! moyaResponse.mapJSON()
                    //    print(dic)
                        guard let dict: [String: Any] = try moyaResponse.mapJSON() as? [String: Any] else {
                            onFailure("Failed to parse")
                            return
                        }
                        guard let message = dict["status_message"] else {
                            onFailure("Failed to parse")
                            return
                        }
                        onFailure(message as? String ?? "No Value")
                    } catch {
                        onFailure("Something went wrong")
                    }
                }
            case let .failure(error):
                print(error.errorDescription ?? "Error")
                onFailure("No Internet")
            }
        }
    }
    /**
     This method will call register api.
     It has two Clousers will be called in Controller.
     - Parameter user_id: The UserID of user  in String formate.
     - Parameter text: Message text  entered by user in string formate.
     - Parameter onSuccess: If everything goes right.
     - Parameter onFailure: In case of any error.
     - Returns: Nothing.
     */
    func imageInteract(imageData: Data?, onSuccess: @escaping (_ message: String) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        let id = UserDefaults.standard.string(forKey: "user_id") ?? ""
        let params: [String: Any] = ["personality": "Happy",
                                     "user_id": id]
        print(params)
        MoyaApiManager.shared.provider.request(.imageInteract(image: imageData, params: params)) { (result) in
            switch result {
                
            case let .success(moyaResponse):
                let statusCode = moyaResponse.statusCode
                switch statusCode {
                case 200:
                    do {
                        guard let response = try moyaResponse.mapJSON() as? [String:Any] else {return}
                        print(response)
                        guard let message = response["caption"] as? String else {return}
                        onSuccess(message)
                    } catch {
                        onFailure("Something went wrong")
                    }
                default:
                    do {
                      //  let dic = try! moyaResponse.mapJSON()
                    //    print(dic)
                        guard let dict: [String: Any] = try moyaResponse.mapJSON() as? [String: Any] else {
                            onFailure("Failed to parse")
                            return
                        }
                        guard let message = dict["status_message"] else {
                            onFailure("Failed to parse")
                            return
                        }
                        onFailure(message as? String ?? "No Value")
                    } catch {
                        onFailure("Something went wrong")
                    }
                }
            case let .failure(error):
                print(error.errorDescription ?? "Error")
                onFailure("No Internet")
            }
        }
    }
    /**
     This method will call register api.
     It has two Clousers will be called in Controller.
     - Parameter user_id: The UserID of user  in String formate.
     - Parameter text: Message text  entered by user in string formate.
     - Parameter onSuccess: If everything goes right.
     - Parameter onFailure: In case of any error.
     - Returns: Nothing.
     */
    func sendEmoji(text: String, onSuccess: @escaping (_ message: String) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        let id = UserDefaults.standard.string(forKey: "user_id") ?? ""
        MoyaApiManager.shared.provider.request(.emoji(text: text, user_id: id)) { (result) in
            switch result {
                
            case let .success(moyaResponse):
                let statusCode = moyaResponse.statusCode
                switch statusCode {
                case 200:
                    do {
                        guard let response = try moyaResponse.mapJSON() as? [String:Any] else {return}
                        print(response)
                        guard let message = response["emoji"] as? String else {return}
                        onSuccess(message)
                    } catch {
                        onFailure("Something went wrong")
                    }
                default:
                    do {
                      //  let dic = try! moyaResponse.mapJSON()
                    //    print(dic)
                        guard let dict: [String: Any] = try moyaResponse.mapJSON() as? [String: Any] else {
                            onFailure("Failed to parse")
                            return
                        }
                        guard let message = dict["status_message"] else {
                            onFailure("Failed to parse")
                            return
                        }
                        onFailure(message as? String ?? "No Value")
                    } catch {
                        onFailure("Something went wrong")
                    }
                }
            case let .failure(error):
                print(error.errorDescription ?? "Error")
                onFailure("No Internet")
            }
        }
    }
    /**
     This method will call register api.
     It has two Clousers will be called in Controller.
     - Parameter user_id: The UserID of user  in String formate.
     - Parameter text: Message text  entered by user in string formate.
     - Parameter onSuccess: If everything goes right.
     - Parameter onFailure: In case of any error.
     - Returns: Nothing.
     */
    func reportMessage(message: String, onSuccess: (() -> Void)? = nil, onFailure: ((_ error: String) -> Void)? = nil) {
        let id = UserDefaults.standard.string(forKey: "user_id") ?? ""
        MoyaApiManager.shared.provider.request(.reportMessage(user_id: id, message: message)) { (result) in
            switch result {
            case let .success(moyaResponse):
                let statusCode = moyaResponse.statusCode
                switch statusCode {
                case 200:
                    onSuccess?()
                default:
                    do {
                        //  let dic = try! moyaResponse.mapJSON()
                        //    print(dic)
                        guard let dict: [String: Any] = try moyaResponse.mapJSON() as? [String: Any] else {
                            onFailure?("Failed to parse")
                            return
                        }
                        guard let message = dict["status_message"] else {
                            onFailure?("Failed to parse")
                            return
                        }
                        onFailure?(message as? String ?? "No Value")
                    } catch {
                        onFailure?("Something went wrong")
                    }
                }
            case let .failure(error):
                print(error.errorDescription ?? "Error")
                onFailure?("No Internet")
            }
        }
    }
   
    
    
}
