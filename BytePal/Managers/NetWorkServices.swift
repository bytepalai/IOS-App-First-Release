//
//  NetWorkServices.swift
//  CargoLine
//
//  Created by Zain
//  Copyright © 2020 ZeeTech. All rights reserved.
//

import Foundation
import Moya
/**
 The purpose of the `ApiManager` is to provide an Shared instant to get access of Moya services.
 This will be used to get any network service.
 
 - Note:
 Moya is a third party library, Latest version of Alamofire. It works on Enum structure.
 */
class MoyaApiManager {
    static let shared = MoyaApiManager()
    /// An instant to access Network Service Enum.
    let provider: MoyaProvider<NetworkService>
    private init() {
        self.provider = MoyaProvider<NetworkService>()
    }
}
/**
 All Network services will be called here in a simple enum.
 Just make a new "case" in case of calling new APi.
 */
enum NetworkService {
    case login(email: String, password: String)
    case register(first_name: String, last_name: String, email: String, password: String)
    case uploadImage(image:Data)
    case create_agent(user_id: String)
    case interact(user_id: String, text: String, type: String)
    case imageInteract(image: Data?, params: [String: Any])
    case emoji(text: String, user_id: String)
    case reportMessage(user_id: String, message: String)
    case history(user_id: String)
}
// MARK: - TargetType Protocol Implementation
extension NetworkService: TargetType {
    /// Main URL to be set
    
    var baseURL: URL {
        switch self {
//        case .imageInteract:
//            return URL(string: "http://34.73.221.176:8081/")!
//        case .emoji:
//            return URL(string: "http://34.73.221.176:5001/")!
        default:
            return URL(string: "https://api.bytepal.io/")!
        }
        
    }
    /// End points of all cases you make in enum.
    var path: String {
        switch self {
        case .login:
            return "/login"
        case .register:
            return "register"
        case .create_agent:
            return "create_agent"
        case .interact:
            return "interact"
        case .uploadImage:
            return "upload/uploadFile"
        case .imageInteract:
            return "image_interact"
        case .emoji:
            return "emoji"
        case .reportMessage:
            return "report"
        case .history:
            return "history"
        }
    }
    /// What type of method it will be? Post,Get,Pull etc
    var method: Moya.Method {
        switch self {
        case .login, .uploadImage, .create_agent, .register, .interact, .imageInteract, .emoji, .reportMessage, .history:
            return .post
        }
    }
    
    var sampleData: Data {
        switch self {
        case .login(let email, let password):
            return "{  \n   \"email\":\"\(email)\",\n   \"password\":\"\(password)\"\n}".data(using: String.Encoding.utf8)!
        case .uploadImage, .create_agent, .register, .interact, .imageInteract, .emoji, .reportMessage, .history:
            return Data()
        }
    }
    
    
    /// Handle your task here, Add parameters here
    var task: Task {
        switch self {
        case let .login(email: email, password: password):
            let data = "{  \n   \"email\":\"\(email)\",\n   \"password\":\"\(password)\"\n}".data(using: String.Encoding.utf8)!
            return .requestData(data)
        case let .uploadImage(image: image):
            var formData = [Moya.MultipartFormData]()
            formData.append(Moya.MultipartFormData(provider: .data(image), name: "avatar", fileName: "invoice.jpeg", mimeType: "invoice/jpeg"))
            return .uploadMultipart(formData)
        case let .register(first_name: first_name, last_name: last_name, email: email, password: password):
            let data = """
        {
            \"email\": \"\(email)\",
            \"password\": \"\(password)\",
            \"first_name\": \"\(first_name)\",
            \"last_name\": \"\(last_name)\"
        }
        """.data(using: String.Encoding.utf8)!
            return .requestData(data)
        case let .create_agent(user_id: user_id):
            let data = """
        {
            \"user_id\" : "\(user_id)"
        }
        """.data(using: String.Encoding.utf8)!
            return .requestData(data)
        case let .interact(user_id: user_id, text: text, type: type):
            let params: [String: Any] = ["user_id": user_id, "text": text, "type": type]
            let paramData = try! JSONSerialization.data(withJSONObject: params)
            return .requestData(paramData)
        case let .imageInteract(image: Image, params: params):
            var formData = [Moya.MultipartFormData]()
            if let imgData = Image {
                formData.append(Moya.MultipartFormData(provider: .data(imgData), name: "image", fileName: "image.jpeg", mimeType: "image/jpeg"))
            }
            let _ = params.map{formData.append(Moya.MultipartFormData(provider: .data("\($0.value)".data(using: .utf8)!), name: "\($0.key)"))}
            return .uploadMultipart(formData)
            
        case let .emoji(text: text, user_id: user_id):
            let params: [String: Any] = ["text": text, "user_id": user_id]
            let paramData = try! JSONSerialization.data(withJSONObject: params)
            return .requestData(paramData)
        case let .reportMessage(user_id: user_id, message: message):
            let params: [String: Any] = ["user_id": user_id, "message": message]
            let paramData = try! JSONSerialization.data(withJSONObject: params)
            return .requestData(paramData)
        case let .history(user_id: user_id):
            let params: [String: Any] = ["user_id": user_id]
            let paramData = try! JSONSerialization.data(withJSONObject: params)
            return .requestData(paramData)
        }
    }//End of Task
    /// Header for each End Path.
    var headers: [String: String]? {
        switch self {
        case .login, .create_agent, .register, .interact, .emoji, .reportMessage, .history:
            return [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
            
        case .uploadImage, .imageInteract:
            return [
                "Content-Type": "multipart/form-data",
                "Accept": "application/json"
            ]
        }
    }
}

