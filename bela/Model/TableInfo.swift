//
//  TableInfo.swift
//  bela
//
//  Created by Kresimir Prcela on 08/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation
import SwiftyJSON

struct TableInfo
{
    let id: String
    let capacity: Int
    let playersId: [String]
    let bet: Int64
    let isPrivate: Bool
    let matchInfo: MatchInfo?
    let playersForRematch: [String]
    let matchResult: MatchResult?
    
    init(json: JSON) {
        id = json["id"].stringValue
        capacity = json["capacity"].intValue
        playersId = json["players_id"].arrayValue.map({ (json) -> String in
            return json.stringValue
        })
        bet = json["bet"].int64Value
        isPrivate = json["private"].boolValue
        matchInfo = nil
        playersForRematch = json["players_for_rematch"].arrayValue.map({ (json) -> String in
            return json.stringValue
        })
        matchResult = nil
    }
}
