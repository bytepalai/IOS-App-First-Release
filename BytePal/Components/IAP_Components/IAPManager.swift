//
//  IAPManager.swift
//  BytePal
//
//  Created by Paul Ngouchet on 8/24/20.
//  Copyright © 2020 BytePal AI, LLC. All rights reserved.
//


import UIKit
import StoreKit

public typealias SuccessBlock = () -> Void
public typealias FailureBlock = (Error?) -> Void
public typealias ProductsBlock = ([SKProduct]) -> Void

let IAP_PRODUCTS_DID_LOAD_NOTIFICATION = Notification.Name("IAP_PRODUCTS_DID_LOAD_NOTIFICATION")

class IAPManager : NSObject{

    private var sharedSecret = ""
    
    // Make singelton object
    @objc static let shared = IAPManager()
    @objc private(set) var products = [SKProduct]()
    
    // BytePal server variable
    var userID: String?
    
    // Store Kit server variable
    private override init(){}

    private var productIds : Set<String> = []

    private var didLoadsProducts : ProductsBlock?

    private var successBlock : SuccessBlock?
    private var failureBlock : FailureBlock?

    private var refreshSubscriptionSuccessBlock : SuccessBlock?
    private var refreshSubscriptionFailureBlock : FailureBlock?

    // MARK:- Main methods

    // Init
    @objc func startWith(arrayOfIds : Set<String>!, sharedSecret : String, callback : @escaping  ProductsBlock){
        SKPaymentQueue.default().add(self)
        self.didLoadsProducts = callback
        self.sharedSecret = sharedSecret
        self.productIds = arrayOfIds // The error is happening right here
        
        loadProducts()
    }
    
    func initIAP(userID: String) {
        IAPManager.shared.userID = userID
        ProductsStore.shared.initializeProducts()
    }

    func expirationDateFor(_ identifier : String) -> Date?{
        return UserDefaults.standard.object(forKey: identifier) as? Date
    }

    func isActive(product : SKProduct) -> Bool {
        if let date = expirationDateFor(product.productIdentifier), Date() < date {
            return true
        } else {
            return false
        }
    }

    func purchaseProduct(product : SKProduct, success: @escaping SuccessBlock, failure: @escaping FailureBlock){
        
        guard SKPaymentQueue.canMakePayments() else {
            return
        }
        guard SKPaymentQueue.default().transactions.last?.transactionState != .purchasing else {
            return
        }
        self.successBlock = success
        self.failureBlock = failure
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    func restorePurchases(success: @escaping SuccessBlock, failure: @escaping FailureBlock){
        self.successBlock = success
        self.failureBlock = failure
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    /* It's the most simple way to send verify receipt request. Consider this code as for learning purposes. You shouldn't use current code in production apps.
     This code doesn't handle errors.
     */
    func refreshSubscriptionsStatus(userID: String, callback : @escaping SuccessBlock, failure : @escaping FailureBlock){
        self.refreshSubscriptionSuccessBlock = callback
        self.refreshSubscriptionFailureBlock = failure

        guard let receiptUrl = Bundle.main.appStoreReceiptURL else {
            refreshReceipt()
            // do not call block in this case. It will be called inside after receipt refreshing finishes.
            return
        }

        #if DEBUG
        let urlString = "https://sandbox.itunes.apple.com/verifyReceipt"
        #else
        let urlString = "https://buy.itunes.apple.com/verifyReceipt"
        #endif
        
        let receiptData = try? Data(contentsOf: receiptUrl).base64EncodedString()
        let requestData = ["receipt-data" : receiptData ?? "", "password" : self.sharedSecret, "exclude-old-transactions" : true] as [String : Any]
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        let httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: [])
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request)  { (data, response, error) in
            DispatchQueue.main.async {
                if data != nil {
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments){
                        self.parseReceipt(userID: userID, json as! Dictionary<String, Any>, url:receiptUrl)
                        return
                    }
                } else {
                    print("error validating receipt: \(error?.localizedDescription ?? "")")
                }
                self.refreshSubscriptionFailureBlock?(error)
                self.cleanUpRefeshReceiptBlocks()
            }
            }.resume()
    }

    /* It's the most simple way to get latest expiration date. Consider this code as for learning purposes. You shouldn't use current code in production apps.
     This code doesn't handle errors or some situations like cancellation date.
     */
    private func parseReceipt(userID:String, _ json : Dictionary<String, Any>, url:URL ) {
        guard let receipts_array = json["latest_receipt_info"] as? [Dictionary<String, Any>] else {
            self.refreshSubscriptionFailureBlock?(nil)
            self.cleanUpRefeshReceiptBlocks()
            return
        }
        let latestReceipt = json["latest_receipt"] as! String

        for receipt in receipts_array {
            let productID = receipt["product_id"] as! String

            let receiptUrl = "\(url)" // URL Type to String to be saved in the database
            let originalTransactionId = receipt["original_transaction_id"] as! String
            let purchaseDateMs = receipt["purchase_date_ms"] as! String
            let expiresDateMs = receipt["expires_date_ms"] as! String
            let webOrderLineItemId = receipt["web_order_line_item_id"] as! String

            // Post the receipt data to the backend
            Receipt.sendReceipt(userID: userID,
                                productID: productID,
                                receiptUrl: receiptUrl,
                                originalTransactionId: originalTransactionId,
                                purchaseDateMs: purchaseDateMs,
                                expiresDateMs: expiresDateMs,
                                latestReceipt:latestReceipt,
                                webOrderLineItemId: webOrderLineItemId)

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
            if let date = formatter.date(from: receipt["expires_date"] as! String) {
                if date > Date() || UserDefaults.standard.object(forKey: productID) == nil{
                    // do not save expired date to user defaults to avoid overwriting with expired date
                    UserDefaults.standard.set(date, forKey: productID)
                }
            }
        }
        self.refreshSubscriptionSuccessBlock?()
        self.cleanUpRefeshReceiptBlocks()
    }

    /*
     Private method. Should not be called directly. Call refreshSubscriptionsStatus instead.
     */
    private func refreshReceipt() {
        let request = SKReceiptRefreshRequest(receiptProperties: nil)
        request.delegate = self
        request.start()
    }

    private func loadProducts(){
        let request = SKProductsRequest.init(productIdentifiers: productIds)
        request.delegate = self
        request.start()
    }
    
//    private func sortProducts(products: [SKProduct], completion: @escaping ([SKProduct]) -> Void) {
//        for index in 1..<products.count {
//            var value = products[index].price.doubleValue
//            var product = products[index]
//            var position = index
//
//            while position > 0 && products[position - 1].price.doubleValue > value {
//                self.products[position] = products[position - 1]
//                position -= 1
//            }
//
//            self.products[position] = product
//        }
//
//        completion(products)
//    }

    private func cleanUpRefeshReceiptBlocks(){
        self.refreshSubscriptionSuccessBlock = nil
        self.refreshSubscriptionFailureBlock = nil
    }
}

// MARK:- SKReceipt Refresh Request Delegate

extension IAPManager : SKRequestDelegate {

    func requestDidFinish(_ request: SKRequest) {
        if request is SKReceiptRefreshRequest {
            refreshSubscriptionsStatus(userID: self.userID!,callback: self.successBlock ?? {}, failure: self.failureBlock ?? {_ in})
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error){
        if request is SKReceiptRefreshRequest {
            self.refreshSubscriptionFailureBlock?(error)
            self.cleanUpRefeshReceiptBlocks()
        }
        print("error: \(error.localizedDescription)")
    }
}

extension SKProduct {
    
}

// MARK:- SKProducts Request Delegate

extension IAPManager: SKProductsRequestDelegate {

    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        // Load products
        products = response.products
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: IAP_PRODUCTS_DID_LOAD_NOTIFICATION, object: nil)
            
            if response.products.count > 0 {
                self.didLoadsProducts?(self.products)
                self.didLoadsProducts = nil
            }

        }
    }
}

// MARK:- SKPayment Transaction Observer

extension IAPManager: SKPaymentTransactionObserver {

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                notifyIsPurchased(transaction: transaction)
                break
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                print("purchase error : \(transaction.error?.localizedDescription ?? "")")
                self.failureBlock?(transaction.error)
                cleanUp()
                break
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                notifyIsPurchased(transaction: transaction)
                break
            case .deferred, .purchasing:
                break
            default:
                break
            }
        }
    }

    private func notifyIsPurchased(transaction: SKPaymentTransaction) {
        refreshSubscriptionsStatus(
            userID: self.userID!,
            callback: {
            self.successBlock?()
            self.cleanUp()
        }) { (error) in
            // couldn't verify receipt
            self.failureBlock?(error)
            self.cleanUp()
        }
    }

    func cleanUp(){
        self.successBlock = nil
        self.failureBlock = nil
    }
}
