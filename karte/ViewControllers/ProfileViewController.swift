//
//  ProfileViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 16/12/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig
import SwiftyStoreKit
import Crashlytics
import Firebase

class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var playerNameLbl: UILabel!
    @IBOutlet weak var countryLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var diamondsLbl: UILabel!
    @IBOutlet weak var buyDiamondsBtn: UIButton!
    @IBOutlet weak var buyDiamonds2xBtn: UIButton!
    @IBOutlet weak var flagBtn: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(updateDiamonds), name: PlayerStat.DiamondsChanged, object: nil)
        nc.addObserver(self, selector: #selector(onFlagSet), name: PlayerStat.FlagChanged, object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        for view in [editBtn, buyDiamondsBtn, buyDiamonds2xBtn, flagBtn]
        {
            view?.layer.borderWidth = 1
            view?.layer.cornerRadius = 5
            view?.layer.borderColor = UIColor.lightText.cgColor
        }
        
        playerNameLbl.text = PlayerStat.shared.alias
        countryLbl.text = lstr("Country")
        editBtn.setTitle(lstr("Edit"), for: .normal)
        flagBtn.setTitle(PlayerStat.shared.flag, for: .normal)
        
        diamondsLbl.text = "\(PlayerStat.shared.diamonds) 💎"
        
        let diamondsQuantity = RemoteConfig.remoteConfig()["purchase_diamonds_quantity"].numberValue!.intValue
        let diamondsQuantity2x = RemoteConfig.remoteConfig()["purchase_diamonds_quantity_2x"].numberValue!.intValue
        
        
        if let idx = retrievedProducts?.index(where: {product in
            return product.productIdentifier == purchaseDiamondsId
        }) {
            let product = retrievedProducts![idx]
            let numberFormatter = NumberFormatter()
            numberFormatter.locale = product.priceLocale
            numberFormatter.numberStyle = .currency
            let priceString = numberFormatter.string(from: product.price ) ?? ""
            buyDiamondsBtn.setTitle("+\(diamondsQuantity) 💎 \(priceString)", for: .normal)
        } else
        {
            buyDiamondsBtn.setTitle("+\(diamondsQuantity) 💎", for: .normal)
        }
        
        if let idx = retrievedProducts?.index(where: { (product) -> Bool in
            return product.productIdentifier == purchaseDiamonds2xId
        }) {
            let product = retrievedProducts![idx]
            let numberFormatter = NumberFormatter()
            numberFormatter.locale = product.priceLocale
            numberFormatter.numberStyle = .currency
            let priceString = numberFormatter.string(from: product.price ) ?? ""
            buyDiamonds2xBtn.setTitle("+\(diamondsQuantity2x) 💎 \(priceString)", for: UIControlState())
        }
        else
        {
            buyDiamonds2xBtn.setTitle("+\(diamondsQuantity2x) 💎", for: .normal)
        }
        
        
    }
    
    @objc func updateDiamonds()
    {
        diamondsLbl.text = "\(PlayerStat.shared.diamonds) 💎"
    }
    
    @objc func onFlagSet()
    {
        flagBtn.setTitle(PlayerStat.shared.flag, for: .normal)
    }
    
    @IBAction func editName(_ sender: AnyObject)
    {
        editNameInPopup()
    }
    
    func editNameInPopup()
    {
        let alert = UIAlertController(title: appName, message: lstr("Input your name"), preferredStyle: .alert)
        alert.addTextField { (textField) in
            let alias = PlayerStat.shared.alias
            textField.text = alias
            textField.placeholder = lstr("Name")
        }
        alert.addAction(UIAlertAction(title: lstr("Cancel"), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let newAlias = alert.textFields?.first?.text
            {
                PlayerStat.shared.alias = newAlias
                self.playerNameLbl.text = newAlias
                PlayerStat.shared.updateToServer()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func buyDiamonds(productId: String, quantity: Int)
    {
        SwiftyStoreKit.purchaseProduct(productId) { result in
            switch result {
            case .success(let product):
                print("Purchase Success: \(product.productId)")
                DispatchQueue.main.async (execute: {
                    
                    PlayerStat.shared.diamonds += quantity
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
    
    @IBAction func buyDiamonds(_ sender: AnyObject)
    {
        let diamondsQuantity = RemoteConfig.remoteConfig()["purchase_diamonds_quantity"].numberValue!.intValue
        buyDiamonds(productId: purchaseDiamondsId, quantity: diamondsQuantity)
    }
    
    @IBAction func buyDiamonds2x(_ sender: Any) {
        let diamondsQuantity = RemoteConfig.remoteConfig()["purchase_diamonds_quantity_2x"].numberValue!.intValue
        buyDiamonds(productId: purchaseDiamonds2xId, quantity: diamondsQuantity)
    }
    
}

