//
//  MessageScrollView.swift
//  BytePal
//
//  Created by Scott Hom on 11/24/20.
//  Copyright © 2020 BytePal-AI. All rights reserved.
//

import SwiftUI

struct MessageScrollView: View {
    
    // Arguments
    var width: CGFloat?
    var height: CGFloat?
    
    // Environment Object
    
    //// Message list
    @EnvironmentObject var messages: Messages
    // Observable Objects
    
    //// Keyboard state and attributes
    //    @ObservedObject var keyboard = KeyboardResponder()

    var body: some View {
        // Render messages (height: 72%)
        if #available(iOS 14.0, *) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach((0 ..< self.messages.list.count), id: \.self) { i in
                        // Message
                        MessageView(id: self.messages.list[i]["id"] as! UUID, message: MessageInformation(content: (self.messages.list[i]["content"] as? String) ?? "", isCurrentUser: self.messages.list[i]["isCurrentUser"] as! Bool))
                            .rotationEffect(.radians(.pi))
                            .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .rotationEffect(.radians(.pi))
        } else {
            List {
                ForEach((0 ..< self.messages.list.count), id: \.self) { i in
                    // Message
                    MessageView(id: self.messages.list[i]["id"] as! UUID, message: MessageInformation(content: (self.messages.list[i]["content"] as? String) ?? "", isCurrentUser: self.messages.list[i]["isCurrentUser"] as! Bool))
                        .rotationEffect(.radians(.pi))
                        .buttonStyle(PlainButtonStyle())
                }
                
            }
            .frame(
                width: (width ?? CGFloat(100))
            )
            .listSeparatorStyle(style: .none)
            .rotationEffect(.radians(.pi))
            .onAppear {
                UITableView.appearance().separatorStyle = .none
                print("----- messages (ScrollView): ")
                print(messages.list)
            }
            .onTapGesture(perform: {
            })
        }
    }
}


struct ListSeparatorStyle: ViewModifier {
    
    let style: UITableViewCell.SeparatorStyle
    
    func body(content: Content) -> some View {
        content
            .onAppear() {
                UITableView.appearance().separatorStyle = self.style
            }
    }
}
extension View {
    
    func listSeparatorStyle(style: UITableViewCell.SeparatorStyle) -> some View {
        ModifiedContent(content: self, modifier: ListSeparatorStyle(style: style))
    }
}
