//
//  StatItem.swift
//  bela
//
//  Created by Kresimir Prcela on 06/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation
import SwiftyJSON

enum Result: Int {
    case loser = -1
    case drawn
    case winner
}

class StatItem: NSObject,NSCoding
{
    let playerId: String
    let score: UInt
    let result: Result
    let bet: Int
    let timestamp: Date
    
    init(playerId: String, score: UInt, result: Result, bet: Int, timestamp: Date)
    {
        self.playerId = playerId
        self.score = score
        self.result = result
        self.bet = bet
        self.timestamp = timestamp
    }
    
    init(json: JSON)
    {
        playerId = json["player_id"].stringValue
        score = json["score"].uIntValue
        result = Result(rawValue: json["result"].intValue)!
        bet = json["bet"].intValue
        timestamp = Date(RFC3339: json["timestamp"].stringValue)
    }
    
    func json() -> JSON
    {
        let dic: [String:Any] = [
            "player_id": playerId,
            "score": score,
            "result": result.rawValue,
            "bet": bet,
            "timestamp": timestamp.stringWithRFC3339Format()
        ]
        return JSON(dic)
    }
    
    // MARK: NSCoding
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(playerId, forKey: "playerId")
        aCoder.encode(Int(score), forKey: "score")
        aCoder.encode(result.rawValue, forKey: "result")
        aCoder.encode(bet, forKey: "bet")
        aCoder.encode(timestamp, forKey: "timestamp")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        playerId = aDecoder.containsValue(forKey: "playerId") ? aDecoder.decodeObject(forKey: "playerId") as! String : ""
        score = UInt(aDecoder.decodeInteger(forKey: "score"))
        result = Result(rawValue: aDecoder.decodeInteger(forKey: "result"))!
        bet = aDecoder.decodeInteger(forKey: "bet")
        timestamp = aDecoder.decodeObject(forKey: "timestamp") as! Date
        super.init()
    }
}
