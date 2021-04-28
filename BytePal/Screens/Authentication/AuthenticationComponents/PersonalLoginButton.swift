//
//  PersonalLoginButton.swift
//  BytePal
//
//  Created by Scott Hom on 11/5/20.
//  Copyright © 2020 BytePal-AI. All rights reserved.
//

import SwiftUI

// PersonalLoginButton (height: 7%)
struct PersonalLoginButton: View {
    
    // Arguments
    var width: CGFloat?
    @Binding var isHiddenLoginView: Bool
    @Binding var isHiddenChatView: Bool
    @Binding var isHiddenSignupView: Bool
    
    // Environment Object
    @EnvironmentObject var messages: Messages
    @EnvironmentObject var userInformation: UserInformation
    @EnvironmentObject var googleDelegate: GoogleDelegate
    
    var body: some View {
        Button(action: {
            self.isHiddenLoginView = true
            self.isHiddenSignupView = false
        }, label: {
            Image(systemName: "envelope.fill")
                .font(.system(size: 20))
                .foregroundColor(Color(UIColor.white))
                .shadow(color: Color(UIColor.black).opacity(app_settings.shadow), radius: 6, x: 3, y: 3)
                .background(
                    Circle()
                        .fill(convertHextoRGB(hexColor: "1757A8"))
                        .frame(width: CGFloat(36), height: CGFloat(36))
                        .shadow(color: Color(UIColor.black).opacity(app_settings.shadow), radius: 6, x: 3, y: 3)
                )
                    .padding(EdgeInsets(top: 0, leading: (width ?? CGFloat(100))*0.04, bottom: 0, trailing: (width ?? CGFloat(100))*0.05))
        })
    }
}
