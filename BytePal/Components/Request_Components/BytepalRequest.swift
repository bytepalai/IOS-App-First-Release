//
//  BytepalRequest.swift
//  BytePal
//
//  Created by Paul Ngouchet on 8/24/20.
//  Copyright © 2020 BytePal AI, LLC. All rights reserved.
//

import Foundation
import AVFoundation
import Alamofire

class MakeRequest {
    static func sendMessage(message: String,
                            userID: String,
                            completion: @escaping (String, String) -> Void) {

        print("----------- userID (SEND): \(userID)")
        
        var responseFromChatBot: String?
        var voicePath : String?
        //      Define header of POST Request
        let urlRequest =  "\(API_HOSTNAME)/interact"
        
        var request = URLRequest(url: URL(string: "\(API_HOSTNAME)/interact")!,
                                 timeoutInterval: Double.infinity)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        //Define body of POST Request
        let parameters: Parameters = [
            "user_id": userID,
            "text":message,
            "type":"user"
        ]
        
        Download.downloadWav(url: urlRequest, parameters:parameters){
            response1, response2 in
            responseFromChatBot = response1
            voicePath = response2
            completion(responseFromChatBot!, voicePath!)
        }
    }
    
}
