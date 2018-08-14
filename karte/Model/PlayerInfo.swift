//
//  PlayerInfo.swift
//  bela
//
//  Created by Kresimir Prcela on 08/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation
import SwiftyJSON

struct PlayerInfo
{
    let id: String
    let alias: String
    let diamonds: Int
    let retentions: [Int]
    var tableId: String?
    
    init(json: JSON) {
        id = json["id"].stringValue
        alias = json["alias"].stringValue
        diamonds = json["diamonds"].intValue
        retentions = json["retentions"].arrayValue.map({ (json) -> Int in
            return json.intValue
        })
        tableId = json["table_id"].string
    }
}
