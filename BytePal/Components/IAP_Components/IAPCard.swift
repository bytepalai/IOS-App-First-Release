//
//  IAPCard.swift
//  BytePal
//
//  Created by Paul Ngouchet on 8/28/20.
//  Copyright © 2020 BytePal-AI. All rights reserved.
//

import SwiftUI



struct IAPCard: View {
    
    // Arguments
    var identifier: String
    
    var body: some View {
        
        
        ZStack{
        RoundedRectangle(cornerRadius: 25, style: .continuous)
            .fill(convertHextoRGB(hexColor: "ffffff"))
            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
//            .shadow(color: convertHextoRGB(hexColor: "000000").opacity(0.33), radius: 4, x: 3, y: 3)
            
        HStack {
            Image(MAPIAP[identifier]![0])
                .renderingMode(.original)
                .resizable()
                .frame(width: 80, height: 80)
                
            HStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(MAPIAP[identifier]![1])
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Text(MAPIAP[identifier]![2])
                            .font(.headline)
                            .fontWeight(.black)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    }
                    .layoutPriority(100)
                    Spacer()
                    
                }
                .padding()
            }
            Text(MAPIAP[identifier]![3].uppercased())
                .font(.system(size: 18))
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

        }
        
        .padding([.horizontal])
        .frame(height: 100, alignment: .center)
        .background(convertHextoRGB(hexColor:"f8f4f4"))
        .clipShape(RoundedCorner(radius: 20, corners: .allCorners))
        }
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct IAPCard_Previews: PreviewProvider {
    static var previews: some View {
        IAPCard(identifier:"BytePal.AI.Unlimited.Messages.Subscription")
            .padding([.leading, .trailing])
    }
}
