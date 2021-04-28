//
//  IAPModel.swift
//  BytePal
//
//  Created by Scott Hom on 10/23/20.
//  Copyright © 2020 BytePal-AI. All rights reserved.
//

import SwiftUI

// Subscription attributes 
class IAPViewModel: ObservableObject {
    var subscriptions = [
        Subscription(
            id: UUID(uuidString: subscription_3) ?? UUID(),
            price: 9.99,
            messageCount: -1,
            imageName: "unlimitedMessages"
        ),
        Subscription(
            id: UUID(uuidString: subscription_2) ?? UUID(),
            price: 7.99,
            messageCount: 2000,
            imageName: "2000Messages"
        ),
        Subscription(
            id: UUID(uuidString: subscription_1) ?? UUID(),
            price: 5.99,
            messageCount: 1000,
            imageName: "1000Messages"
        )
    ]
    
    
    struct Subscription: Identifiable {
        var id: UUID = UUID()
        var price: Double
        var messageCount: Int
        var imageName: String
        
        var messageCountLabel: String {
            messageCount == -1 ? "Unlimited Messages":"\(messageCount) Messages"
        }
        var pricePerMonthLabel: String {
            "$ \(price) / Month "
        }
        
        var image: Image {
            Image(imageName)
        }
    }
}
