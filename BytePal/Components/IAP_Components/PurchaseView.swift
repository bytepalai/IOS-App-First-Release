//
//  ContentView.swift
//  BytePal
//
//  Created by Paul Ngouchet on 8/24/20.
//  Copyright © 2020 BytePal AI, LLC. All rights reserved.
//

import Foundation
import SwiftUI
import StoreKit
import Combine

struct PurchaseView : View {
    
    // Arguments
    var userID: String?
    
    // Environment Variable
    @Environment(\.presentationMode) var presentationMode
    
    // States
    @State private var isDisabled : Bool = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView (showsIndicators: false) {
                VStack {
                    if ProductsStore.shared.products.count != 0 {
                        Text("Get Premium Membership").font(.title)
                            .fontWeight(.black)
                            .foregroundColor(.primary)
                            .lineLimit(3)
                        Text("Choose one of the packages below")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
        
                    self.purchaseButtons(width: geometry.size.width, height: geometry.size.height)
                        .shadow(color: convertHextoRGB(hexColor: "000000").opacity(app_settings.shadow), radius: 6, x: 3, y: 6)
                        
                    //self.aboutText()
                    
                    if ProductsStore.shared.products.count != 0 {
                        ZStack{
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(convertHextoRGB(hexColor: "ffffff"))
                            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
                            VStack {
                                self.helperButtons()
                                self.termsText()//.frame(width: UIScreen.main.bounds.size.width)
                                self.dismissButton()

                            }
                            .background(convertHextoRGB(hexColor:"f8f4f4"))
                        }
                        .cornerRadius(20, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                        .padding([.leading, .trailing, .bottom])
                        .shadow(color: convertHextoRGB(hexColor: "000000").opacity(app_settings.shadow), radius: 6, x: 3, y: 3)
                    }
                }
                .background(convertHextoRGB(hexColor:"ebf6f5"))
                .frame(width : UIScreen.main.bounds.size.width)
            }.disabled(self.isDisabled)
        }
            .navigationBarTitle("")
            .navigationBarHidden(true)
    }

    // MARK:- View creations

    func purchaseButtons(width: CGFloat, height: CGFloat) -> some View {
        // remake to ScrollView if has more than 2 products because they won't fit on screen.
        VStack {
            if ProductsStore.shared.products.count != 0 {
                ForEach(ProductsStore.shared.products, id: \.self) { prod in
                    VStack {
                        PurchaseButton(block: {
                            self.purchaseProduct(userID: self.userID!, skproduct:prod)
                        }, product: prod).disabled(IAPManager.shared.isActive(product:prod))
                        Spacer()
                        Spacer()
                    }
                }
            } else {
                VStack {
                    Image(systemName: "wifi.exclamationmark")
                        .foregroundColor(Color(UIColor.systemGray3))
                        .font(.custom(fontStyle, size: 72))
                        .padding()
                    Text("Unable to load products at this time. Please check your internet connection")
                        .font(.custom(fontStyle, size: 28))
                        .foregroundColor(Color(UIColor.black))
                        .padding()
                }
                    .frame(width: width, height: height)
            }
        }
    }
    
    func helperButtons() -> some View{
        HStack {
            Button(action: {
                self.termsTapped()
            }) {
                Text("Terms of use").font(.footnote)
                    .underline()
                    .foregroundColor(.gray)
            }
            Button(action: {
                self.restorePurchases()
            }) {
                Text("Restore purchases").font(.footnote)
                    .underline()
                    .foregroundColor(.gray)
            }
            Button(action: {
                self.privacyTapped()
            }) {
                Text("Privacy policy").font(.footnote)
                    .underline()
                    .foregroundColor(.gray)
            }
            }.padding()
    }

    func aboutText() -> some View {
        Text("""
                • Unlimited searches
                • 100GB downloads
                • Multiplatform service
                """).font(.subheadline).lineLimit(nil)
    }

    func termsText() -> some View{
        // Set height to 600 because SwiftUI has bug that multiline text is getting cut even if linelimit is nil.
        VStack {
            Text(terms_text).font(.footnote).lineLimit(nil).padding()
            Spacer()
            }.frame(height: 300)
    }

    func dismissButton() -> some View {
        Button(action: {
            self.dismiss()
        }) {
            Text("Not now").font(.footnote)
                .foregroundColor(.gray)
        }.padding()
    }
    
    private func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    }


    //MARK:- Actions

    func restorePurchases(){

        IAPManager.shared.restorePurchases(success: {
            self.isDisabled = false
            ProductsStore.shared.handleUpdateStore()
            self.dismiss()

        }) { (error) in
            self.isDisabled = false
            ProductsStore.shared.handleUpdateStore()

        }
    }

//    Open url in safari
    
    func termsTapped() {
        Utilities.openLink(urlString: links.termsOfUse)
    }

    func privacyTapped() {
        Utilities.openLink(urlString: links.privacyPolicy)
    }

    func purchaseProduct(userID: String, skproduct : SKProduct){
        print("did tap purchase product: \(skproduct.productIdentifier)")
        isDisabled = true
        
        IAPManager.shared.userID = userID
        IAPManager.shared.purchaseProduct(product: skproduct, success: {
            self.isDisabled = false
            ProductsStore.shared.handleUpdateStore()
            self.dismiss()
        }) { (error) in
            self.isDisabled = false
            ProductsStore.shared.handleUpdateStore()
        }
    }
}


struct PurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseView(userID: "Zain")
    }
}
