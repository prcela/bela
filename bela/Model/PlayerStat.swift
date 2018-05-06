//
//  PlayerStat.swift
//  bela
//
//  Created by Kresimir Prcela on 06/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Notification.Name
{
    static let playerDiamondsChanged = NSNotification.Name("Notification.playerDiamondsChanged")
    static let playerStatItemsChanged = NSNotification.Name("Notification.playerStatItemsChanged")
    static let playerAliasChanged = NSNotification.Name("Notification.playerAliasChanged")
}


class PlayerStat: NSObject, NSCoding
{
    static var shared = PlayerStat()
    var id: String
    var alias: String
    
    var diamonds = 100 {
        didSet {
            print("Diamonds didSet: \(diamonds)")
            if diamonds != oldValue {
                NotificationCenter.default.post(name: .playerDiamondsChanged, object: diamonds)
            }
        }
    }
    
    var items = [StatItem]() {
        didSet {
            if items.count != oldValue.count {
                NotificationCenter.default.post(name: .playerStatItemsChanged, object: items)
            }
        }
    }
    
    var tableId: String?
    var retentions = [Int]()
    
    override init() {
        let random64 = Int64(arc4random()) + (Int64(arc4random()) << 32)
        id = String(format: "%x", random64)
        alias = lstr("Player") + "_" + id
        super.init()
    }
    
    init(json: JSON, jsonStatItems: JSON?)
    {
        id = json["id"].stringValue
        alias = json["alias"].stringValue
        diamonds = json["diamonds"].intValue
        retentions = json["retentions"].arrayObject as? [Int] ?? []
        items = jsonStatItems?.arrayValue.map({ (json) -> StatItem in
            return StatItem(json: json)
        }) ?? []
        tableId = json["table_id"].string
    }
    
    func updateToServer()
    {
        WsAPI.shared.send(.UpdatePlayer, json: json())
    }
    
    func json() -> JSON
    {
        let json = JSON(["id":id,
                         "alias":alias,
                         "diamonds": diamonds,
                         "retentions": retentions,
            ])
        return json
    }

    
    fileprivate class func filePath() -> String
    {
        let docURL = FileManager.default.urls(for: .documentDirectory, in: [.userDomainMask]).first!
        let filePath = docURL.appendingPathComponent("PlayerStat").path
        return filePath
    }
    
    class func loadStat()
    {
        if FileManager.default.fileExists(atPath: filePath())
        {
            shared = NSKeyedUnarchiver.unarchiveObject(withFile: filePath()) as! PlayerStat
            print("Loaded stat")
        } else {
            print("player stat file not found, created new stat")
        }
    }
    
    class func saveStat()
    {
        NSKeyedArchiver.archiveRootObject(shared, toFile: filePath())
        print("Saved stat")
    }
    
    // MARK: NSCoding
    private let keyId = "id"
    private let keyAlias = "alias"
    private let keyDiamonds = "diamonds"
    private let keyItems = "items"
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(id, forKey: keyId)
        aCoder.encode(alias, forKey: keyAlias)
        aCoder.encode(diamonds, forKey: keyDiamonds)
        aCoder.encode(items, forKey: keyItems)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        id = aDecoder.decodeObject(forKey: keyId) as! String
        alias = aDecoder.decodeObject(forKey: keyAlias) as! String
        diamonds = aDecoder.decodeInteger(forKey: keyDiamonds)
        items = aDecoder.decodeObject(forKey: keyItems) as! [StatItem]
        super.init()
    }
}
