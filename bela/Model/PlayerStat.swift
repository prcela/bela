//
//  PlayerStat.swift
//  bela
//
//  Created by Kresimir Prcela on 06/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation

class PlayerStat: NSObject, NSCoding
{
    static var shared = PlayerStat()
    var id: String
    var alias: String
    
    override init() {
        let random64 = Int64(arc4random()) + (Int64(arc4random()) << 32)
        id = String(format: "%x", random64)
        alias = lstr("Player") + "_" + id
        super.init()
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
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(id, forKey: keyId)
        aCoder.encode(alias, forKey: keyAlias)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        id = aDecoder.decodeObject(forKey: keyId) as! String
        alias = aDecoder.decodeObject(forKey: keyAlias) as! String
        super.init()
    }
}
