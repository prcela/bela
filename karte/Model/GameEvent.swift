//
//  File.swift
//  karte
//
//  Created by Kresimir Prcela on 18/06/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation
import SwiftyJSON

class GameEvent {
    let category: String
    let action: String
    let label: String?
    let value: Int?
    
    init(json: JSON) {
        category = json["category"].stringValue
        action = json["action"].stringValue
        label = json["label"].string
        value = json["value"].int
    }
}
