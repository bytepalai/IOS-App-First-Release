//
//  Navigation.swift
//  BytePal
//
//  Created by Scott Hom on 7/8/20.
//  Copyright © 2020 BytePal-AI. All rights reserved.
//

import SwiftUI

struct NavigationBar: View {
    
    // Arguments
    var width: CGFloat
    var height: CGFloat
    
    //// Control which view is beign shown
    @Binding var isHiddenHomeView: Bool
    @Binding var isHiddenChatView: Bool
    @Binding var isHiddenAccountSettingsView: Bool
    
    // Environment Object
    @EnvironmentObject var messages: Messages
    @EnvironmentObject var userInformation: UserInformation
    @EnvironmentObject var googleDelegate: GoogleDelegate
    
    var body: some View {
        HStack {
            
            // Home View button
            Button(action: {
                DispatchQueue.main.async {
                    isHiddenHomeView = false
                    isHiddenChatView = true
                    isHiddenAccountSettingsView = true
                }
            }, label: {
                Image(systemName: "house.fill")
                    .font(.system(size: 34))
                    .foregroundColor(convertHextoRGB(hexColor: "EAEEED"))
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 32, trailing: 64))
                    .shadow(color: convertHextoRGB(hexColor: "000000").opacity(app_settings.shadow), radius: 6, x: 3, y: 7)
            })
            
            // Chat View Button
            Button(action: {
                DispatchQueue.main.async {
                    isHiddenHomeView = true
                    isHiddenChatView = false
                    isHiddenAccountSettingsView = true
                }
            }, label: {
                Image(systemName: "bubble.left.fill")
                    .font(.system(size: 34))
                    .foregroundColor(convertHextoRGB(hexColor: "EAEEED"))
                    .shadow(color: convertHextoRGB(hexColor: "000000").opacity(app_settings.shadow), radius: 6, x: 3, y: 7)
                    .padding(EdgeInsets(top: 6, leading: 0, bottom: 32, trailing: 0))
            })
            
            // Settings View Button
            Button(action: {
                DispatchQueue.main.async {
                    isHiddenHomeView = true
                    isHiddenChatView = true
                    isHiddenAccountSettingsView = false
                }
            }, label: {
                Image(systemName: "person.fill")
                    .font(.system(size: 34))
                    .foregroundColor(convertHextoRGB(hexColor: "EAEEED"))
                    .shadow(color: convertHextoRGB(hexColor: "000000").opacity(app_settings.shadow), radius: 6, x: 3, y: 7)
                    .padding(EdgeInsets(top: 0, leading: 64, bottom: 32, trailing: 0))
            })

        }
            .frame(width: width, height: height)
            .background(convertHextoRGB(hexColor: "9FA7A3"))
            .shadow(radius: 1)
    }
}

struct Navigation_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
