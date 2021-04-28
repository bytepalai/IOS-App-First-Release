//
//  PurchaseButton.swift
//  BytePal
//
//  Created by Paul Ngouchet on 8/24/20.
//  Copyright © 2020 BytePal AI, LLC. All rights reserved.
//


import Foundation
import SwiftUI
import StoreKit

struct PurchaseButton : View {
    
    // Arguments
    
    //// Closure for sotre kit success indication
    var block : SuccessBlock!
    
    var product : SKProduct!
    
    var body: some View {
        
        Button(action: {
            
            self.block()
            print("price is", self.product.localizedPrice())
            print(self.product.localizedPrice())
           
        }) {
            
            IAPCard(identifier: String(self.product.productIdentifier))
            
            }
//        .shadow(color: convertHextoRGB(hexColor: "000000").opacity(0.48), radius: 3, x: 3, y: 6)
        .padding([.leading, .trailing])
//        .cornerRadius(20, antialiased: true)
    }
        
}
