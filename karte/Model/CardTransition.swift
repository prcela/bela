//
//  CardTransition.swift
//  karte
//
//  Created by Kresimir Prcela on 20/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation
import SwiftyJSON

struct CardTransition {
    let card: Card
    let fromGroupId: String
    let toGroupId: String
    let toTop: Bool
    let waitDuration: TimeInterval
    let duration: TimeInterval
    
    init(json: JSON)
    {
        card = Card(json: json["card"])
        fromGroupId = json["from_group_id"].stringValue
        toGroupId = json["to_group_id"].stringValue
        toTop = json["to_top"].boolValue
        waitDuration = json["wait_duration"].doubleValue
        duration = json["duration"].doubleValue
    }
}
