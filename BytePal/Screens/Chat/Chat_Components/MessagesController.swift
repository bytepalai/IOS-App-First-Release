//
//  MessagesController.swift
//  BytePal
//
//  Created by Scott Hom on 8/27/20.
//  Copyright © 2020 BytePal-AI. All rights reserved.
//

import Foundation

extension Messages {
    
    
    // Make request to /history endpoint
    func getHistory(userID: String) -> [[String: String]]? {
            
            // Dictionary to store messages
            var messagHistoryData: [[String: String]]?
        
            let semaphore = DispatchSemaphore (value: 0)

    //      Define header of POST Request
            var request = URLRequest(url: URL(string: "\(API_HOSTNAME)/history")!,timeoutInterval: Double.infinity)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
        
    //      Define body of POST Request
            let parameters = """
            {
            \"user_id\": \"\(userID)\"
            }
            """
            let dataPOST = parameters.data(using: .utf8)
            request.httpBody = dataPOST

    //      Create POST Request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
    //          Handle response
                guard let data = data else {
                    print(String(describing: error))
                    return
                }
                do {
                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                    if let responseJSON = responseJSON as? [String: [[String: String]]] {
                        messagHistoryData = responseJSON[userID]
                    }
                    
                    // Ouput HTTP Status Code if status code not success
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode != 200 {
                            print("Error BP: HTTP Status code \(httpResponse.statusCode). \(DebugBP.debug())")
                        }
                    }
                    
                } catch {
                    print(error)
                }
                semaphore.signal()
            }
            task.resume()
            semaphore.wait()
            // Return loginStatus
        
        return messagHistoryData// ?? [["Error" : "Message history was unssucessfuly retrieved"]]
    }

    
    func getMessagesLeft(userID: String) -> String {
            var messagesLeftResponse: String?
            let semaphore = DispatchSemaphore (value: 0)

    //      Define header of POST Request
            var request = URLRequest(url: URL(string: "\(API_HOSTNAME)/messages_left")!,timeoutInterval: Double.infinity)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
        
    //      Define body of POST Request
            let parameters = """
            {
            \"user_id\": \"\(userID)\"
            }
            """
            let dataPOST = parameters.data(using: .utf8)
            request.httpBody = dataPOST
            
    //      Define JSON response format
            struct responseStruct: Decodable {
                var messages_left: String
            }

    //      Create POST Request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
    //          Handle response
                guard let data = data else {
                    print(String(describing: error))
                    return
                }
                do {
                    
                    let reponseObject = try JSONDecoder().decode(responseStruct.self, from: data)
                    let responseData: String = reponseObject.messages_left
                    
                    // remove white spaces on response
                    messagesLeftResponse = responseData.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                } catch {
                    print(error)
                }
                semaphore.signal()
            }
            task.resume()
            semaphore.wait()
        
            // Return loginStatus
            return messagesLeftResponse ?? "Error: Unable to get number of messages left"
        
    }
}
