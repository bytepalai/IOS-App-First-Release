//
//  MessageBubble.swift
//  BytePal
//
//  Created by Paul Ngouchet on 8/25/20.
//  Copyright © 2020 BytePal AI, LLC. All rights reserved.
//

import SwiftUI

// Message bubble
struct MessageBubble: View {
    
    // Arguments
    
    //// Message text
    var message: String
    //// Indicates if the message is the curent user or chatbot
    var isCurrentUser: Bool
    @State var isPresenting = false
    @State var showReportedAlert = false
    
    var body: some View {
        HStack {
            Text(message)
                .padding(12)
                .background(isCurrentUser ? convertHextoRGB(hexColor: greenColor) : convertHextoRGB(hexColor: "ccd6d3"))
                .foregroundColor(isCurrentUser ? Color.white : Color.black)
//                .background(convertHextoRGB(hexColor: "ccd6d3"))
//                .foregroundColor(Color.black)
                .cornerRadius(15)
                .shadow(color: convertHextoRGB(hexColor: "000000").opacity(app_settings.shadow), radius: 6, x: 3, y: 7)
                .font(.custom(fontStyle, size:18))
            Button(action: {
                
            }, label: {
                Text("")
            })
            .alert(isPresented: $showReportedAlert, content: {
                Alert(title: Text("Success"), message: Text("We have received your request."), dismissButton: .cancel(Text("OK")))
            })
            
            Button(action: {
                self.isPresenting = true
            }){
                Text("Report")
            }
            .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 0))
            .isHidden(isCurrentUser, remove: isCurrentUser)
            .alert(isPresented: $isPresenting, content: {
                Alert(title: Text("Report Message?"), message: Text("Your feedback is really important to us. Your feedback will help us to improve communication."), primaryButton: .destructive(Text("Report"), action: {
                    self.reportMessage()
                }), secondaryButton: .cancel(Text("Cancel")))
            })
        }
    }
    
    func reportMessage() {
        APIViewModel.shared.reportMessage(message: self.message) {
            DispatchQueue.main.async {
                self.showReportedAlert = true
            }
        }
    }
}

struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        MessageBubble(message:"Good, morning to you to John",isCurrentUser:false)
    }
}
