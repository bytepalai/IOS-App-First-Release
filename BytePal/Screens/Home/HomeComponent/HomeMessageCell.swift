//
//  HomeMessageCell.swift
//  BytePal
//
//  Created by Scott Hom on 10/23/20.
//  Copyright © 2020 BytePal-AI. All rights reserved.
//

import SwiftUI
import CoreData


struct HomeMessageCell: View {
    
    // Arguments
    
    //// Control which view view is beign shown
    @Binding var isHiddenLoginView: Bool
    @Binding var isHiddenHomeView: Bool
    @Binding var isHiddenChatView: Bool
    
    var messageCreator: messagecreater
    
    var body: some View {
        
        Group{
            
            // Choose to show usercard or chabot card.
            switch messageCreator {
            
            // User card
            case .user:
                    HStack {
                        Spacer(minLength: 40)
                        HStack {
                            
                            MessageBodyTexts(
                                messageCreator: self.messageCreator,
                                isHiddenLoginView: self.$isHiddenLoginView,
                                isHiddenHomeView: self.$isHiddenHomeView,
                                isHiddenChatView: self.$isHiddenChatView
                            )
                            
                            HomeMessageCellImage(messageCreator: messageCreator)
                                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
                        }
                        .padding()
                        .background(getBackgroundColor(accordingTo: messageCreator))
                        .cornerRadius(30)
                    }
                    .transition(.move(edge: .trailing))
            
            // Chatbot card
            case .bytePal:
                HStack {
                    HStack {
                        HomeMessageCellImage(messageCreator: messageCreator)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
                        MessageBodyTexts(
                            messageCreator: messageCreator,
                            isHiddenLoginView: self.$isHiddenLoginView,
                            isHiddenHomeView: self.$isHiddenHomeView,
                            isHiddenChatView: self.$isHiddenChatView
                        )
                    }
                    .padding()
                    .background(getBackgroundColor(accordingTo: messageCreator))
                    .cornerRadius(30)
                    Spacer(minLength: 40)
                }
                .transition(.move(edge: .leading))
            }
        }
        .animation(.interpolatingSpring(stiffness: 30, damping: 8))
        .padding()
    }
    
    // storage for card attributes
    enum messagecreater {
        case user(message: String)
        case bytePal(message: String)

        var title: String {
            switch self {
            case .user:
                return "Your last mesage"
            case .bytePal:
                return "BytePal's last message"
            }
        }
        
        var message: String {
            switch self {
            case .user(let message):
                return message
            case .bytePal(let message):
                return message
            }
        }
    }
    
    // Control the background color of the card
    private func getBackgroundColor(accordingTo messageCreator: messagecreater) -> Color {
        switch messageCreator {
        
        case .user(message: _):
            return .appGreen
            
        case .bytePal(message: _):
            return .appLightGreen2
        }
    }
    
}

//MARK: Sub views
struct MessageBodyTexts: View {
    var messageCreator: HomeMessageCell.messagecreater
    @Binding var isHiddenLoginView: Bool
    @Binding var isHiddenHomeView: Bool
    @Binding var isHiddenChatView: Bool
    
    @FetchRequest(entity: Message.entity(), sortDescriptors: []) var MessagesCoreData: FetchedResults<Message>
    @FetchRequest(entity: User.entity(), sortDescriptors: []) var UserInformationCoreData: FetchedResults<User>
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var messages: Messages
    @EnvironmentObject var userInformation: UserInformation
    @State var isShowingChatView: Bool = false
    
    
    var body: some View {
        VStack(alignment: getAlignment(from: messageCreator)) {
            Text(messageCreator.title)
                .foregroundColor(getMessageTitleColor(acordingTo: messageCreator))
                .fontWeight(.bold)
            Text(messageCreator.message)
                .font(title2Custom)
                .fontWeight(.semibold)
                .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: true)
            
            //here we have given explicit animation so that parents animation will not work here
            Button(action: {
                self.isHiddenHomeView = true
                isHiddenHomeView = true
                isHiddenChatView = false
//                self.isHiddenIAPView = false
            }){
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title)
                    .animation(
                        Animation.interpolatingSpring(stiffness: 50, damping: 10, initialVelocity: 0)
                    )
            }
        }
        .foregroundColor(getFontColor(acordingTo: messageCreator) )
    }
    
    //MARK: Constants and methods
    func getAlignment(from messageCreator: HomeMessageCell.messagecreater) -> HorizontalAlignment {
        
        switch messageCreator {
        
        //chage if needed
        case .user(message: _):
            return .leading
            
        case .bytePal(message: _):
            return .leading
        }
    }
    
    private func getFontColor(acordingTo messageCreator: HomeMessageCell.messagecreater) -> Color {
        switch messageCreator {
        
        case .user(message: _):
            return .white
            
        case .bytePal(message: _):
            return .appFontColorBlack
            
        }
    }
    
    private func getMessageTitleColor(acordingTo messageCreator: HomeMessageCell.messagecreater) -> Color{
        switch messageCreator {
        
        case .user(message: _):
            return .appTransparentGray
            
        case .bytePal(message: _):
            return .gray
            
        }
    }
}

struct HomeMessageCellImage: View {
    var messageCreator: HomeMessageCell.messagecreater

    var body: some View {
        
        VStack {
            getImage(releventTo: messageCreator)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 100, alignment: .top)
            Spacer()
        }
        
    }

    private func getImage(releventTo messageCreator: HomeMessageCell.messagecreater) -> Image {
        
        switch messageCreator {
            //chage if needed
            case .user(message: _):
                return Image("homePerson")
                
            case .bytePal(message: _):
                return Image("homeRobot")
        }
        
    }
    
}
    



