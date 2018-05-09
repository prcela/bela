//
//  UIViewControllerExt.swift
//  bela
//
//  Created by Kresimir Prcela on 09/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig
import SwiftyStoreKit
import Crashlytics


extension UIViewController {
    func suggestBuyDiamonds()
    {
        Answers.logCustomEvent(withName: "SuggestBuyDiamonds", customAttributes: nil)
        
        let message = lstr("Not enough diamonds")
        
        let diamondsQuantity = RemoteConfig.remoteConfig()["purchase_diamonds_quantity"].numberValue!.intValue
        let diamondsQuantity2x = RemoteConfig.remoteConfig()["purchase_diamonds_quantity_2x"].numberValue!.intValue
        
        
        var buyTitle = "+\(diamondsQuantity) 💎"
        var buy2xTitle = "+\(diamondsQuantity2x) 💎"
        
        if let idx = retrievedProducts?.index(where: {product in
            return product.productIdentifier == purchaseDiamondsId
        }) {
            let product = retrievedProducts![idx]
            let numberFormatter = NumberFormatter()
            numberFormatter.locale = product.priceLocale
            numberFormatter.numberStyle = .currency
            if let priceString = numberFormatter.string(from: product.price )
            {
                buyTitle += " \(priceString)"
            }
        }
        
        if let idx = retrievedProducts?.index(where: {product in
            return product.productIdentifier == purchaseDiamonds2xId
        }) {
            let product = retrievedProducts![idx]
            let numberFormatter = NumberFormatter()
            numberFormatter.locale = product.priceLocale
            numberFormatter.numberStyle = .currency
            if let priceString = numberFormatter.string(from: product.price )
            {
                buy2xTitle += " \(priceString)"
            }
        }
        
        let alert = UIAlertController(title: appName, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: lstr("Cancel"), style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: buyTitle, style: .default, handler: { (action) in
            DispatchQueue.main.async {
                self.purchaseProduct(productId: purchaseDiamondsId)
            }
        }))
        
        alert.addAction(UIAlertAction(title: buy2xTitle, style: .default, handler: { (action) in
            DispatchQueue.main.async {
                self.purchaseProduct(productId: purchaseDiamonds2xId)
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func purchaseProduct(productId: String)
    {
        SwiftyStoreKit.purchaseProduct(purchaseDiamondsId) { result in
            switch result {
            case .success(let product):
                print("Purchase Success: \(product.productId)")
                DispatchQueue.main.async (execute: {
                    
                    let diamondsQuantity = RemoteConfig.remoteConfig()["purchase_diamonds_quantity"].numberValue!.intValue
                    PlayerStat.shared.diamonds += diamondsQuantity
                    PlayerStat.shared.updateToServer()
                    
                    if let idx = retrievedProducts?.index(where: {retProduct in
                        return retProduct.productIdentifier == product.productId
                    }) {
                        let product = retrievedProducts![idx]
                        let numberFormatter = NumberFormatter()
                        numberFormatter.locale = product.priceLocale
                        numberFormatter.numberStyle = .currency
                        let currencyCode = numberFormatter.currencyCode
                        
                        Answers.logPurchase(withPrice: product.price,
                                            currency: currencyCode,
                                            success: true,
                                            itemName: "Diamonds",
                                            itemType: nil,
                                            itemId: product.productIdentifier,
                                            customAttributes: [:])
                    }})
                
            case .error(let error):
                print("Purchase Failed: \(error)")
                
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    let alertInfo = UIAlertController(title: appName, message: lstr("Purchase failed"), preferredStyle: .alert)
                    alertInfo.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    (MainViewController.shared?.presentedViewController ?? MainViewController.shared)?.present(alertInfo, animated: true, completion: nil)
                }
            }
        }
    }

}
