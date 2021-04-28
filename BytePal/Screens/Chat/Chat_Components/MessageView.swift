//
//  MessageView.swift
//  BytePal
//
//  Created by Paul Ngouchet on 8/25/20.
//  Copyright © 2020 BytePal AI, LLC. All rights reserved.
//

import SwiftUI

//  Message View
struct MessageView: View, Identifiable {
    
    // Arguments
    
    //// System generated unique alpha numeric string
    var id: UUID
    
    ////  contains message text and wether message is from user or chabot.
    var message: MessageInformation
    
    var body: some View {
        HStack (alignment: .bottom, spacing: 16) {
            if message.isCurrentUser == true { Spacer() }
            MessageBubble(message: message.content, isCurrentUser: message.isCurrentUser)
                .padding(
                    message.isCurrentUser ?
                    EdgeInsets(top: 8, leading: 40, bottom: 8, trailing: 8) :
                    EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 40)
                )
            if message.isCurrentUser == false {Spacer() }
        }
    }
}


struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        let info = MessageInformation(content: "Zain Haider", isCurrentUser: true)
        MessageView(id: UUID.init(uuidString: "asd")!, message: info)
    }
}
