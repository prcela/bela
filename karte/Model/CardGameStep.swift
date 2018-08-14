//
//  CardGameStep.swift
//  karte
//
//  Created by Kresimir Prcela on 14/08/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation
import SwiftyJSON

struct CardGameStep {
    let transitions: [CardTransition]
    var enabledMoves: [Int:[CardEnabledMove]]
    let event: GameEvent?
    
    init(json: JSON) {
        transitions = json["transitions"].arrayValue.map { (json) -> CardTransition in
            return CardTransition(json: json)
        }
        
        enabledMoves = [:]
        for (key,json) in json["enabled_moves"].dictionaryValue {
            enabledMoves[Int(key)!] = json.arrayValue.map({ (json) -> CardEnabledMove in
                return CardEnabledMove(json: json)
            })
        }
        if json["event"].exists() {
            event = GameEvent(json: json["event"])
        } else {
            event = nil
        }
    }
}
