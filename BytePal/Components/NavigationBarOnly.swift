//
//  Navigation.swift
//  BytePal
//
//  Created by Scott Hom on 7/8/20.
//  Copyright © 2020 BytePal-AI. All rights reserved.
//

import SwiftUI

struct NavigationBarOnly: View {
    var width: CGFloat
    var height: CGFloat
    var color: Color
    
    var body: some View {
        
        HStack {
            Image(systemName: "house.fill")
                .font(.system(size: 34))
                .foregroundColor(convertHextoRGB(hexColor: "EAEEED"))
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 32, trailing: 64))
                .shadow(color: convertHextoRGB(hexColor: "000000").opacity(app_settings.shadow), radius: 6, x: 3, y: 7)
            Image(systemName: "bubble.left.fill")
                .font(.system(size: 34))
                .foregroundColor(convertHextoRGB(hexColor: "EAEEED"))
                .shadow(color: convertHextoRGB(hexColor: "000000").opacity(app_settings.shadow), radius: 6, x: 3, y: 7)
                .padding(EdgeInsets(top: 6, leading: 0, bottom: 32, trailing: 0))
            Image(systemName: "person.fill")
                .font(.system(size: 34))
                .foregroundColor(convertHextoRGB(hexColor: "EAEEED"))
                .shadow(color: convertHextoRGB(hexColor: "000000").opacity(app_settings.shadow), radius: 6, x: 3, y: 7)
                .padding(EdgeInsets(top: 0, leading: 64, bottom: 32, trailing: 0))
        }
            .frame(width: width, height: height)
            .background(color)
            .shadow(radius: 1)
        
    }
}

struct NavigationBarOnly_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBarOnly(width: CGFloat(414), height: CGFloat(105), color: Color(UIColor.systemGray3))
    }
}
