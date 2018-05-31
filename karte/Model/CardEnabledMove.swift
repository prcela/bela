//
//  CardEnabledMove.swift
//  bela
//
//  Created by Kresimir Prcela on 27/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation
import SwiftyJSON

struct CardEnabledMove
{
    let fromGroupId: String
    let card: Card
    let toGroupId: String?
    
    init(json: JSON) {
        fromGroupId = json["from_group_id"].stringValue
        card = Card(json: json["card"])
        toGroupId = json["to_group_id"].string
    }
    
    func dictionary() -> [String:Any]
    {
        var dic: [String:Any] = [
            "from_group_id":fromGroupId,
            "card":card.dictionary
        ]
        if let toGroupId = toGroupId {
            dic["to_group_id"] = toGroupId
        }
        return dic
    }
}
