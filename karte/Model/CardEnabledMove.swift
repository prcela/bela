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
    let card: Card
    let toGroupId: String?
    
    init(json: JSON) {
        card = Card(json: json["card"])
        toGroupId = json["to_group_id"].string
    }
}
