//
//  Bela.swift
//  karte
//
//  Created by Kresimir Prcela on 27/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation
import SwiftyJSON

class Bela
{
    var indexOfPlayerOnTurn = 0
    var initialGroup = CardGroup(id: "Initial")
    var centerGroup = CenterGroup(id: "Center")
    var handGroups = [
        LinearGroup(id: "Hand0", capacity: 8, delta: 15),
        LinearGroup(id: "Hand1", capacity: 8, delta: 15),
        LinearGroup(id: "Hand2", capacity: 8, delta: 15),
        LinearGroup(id: "Hand3", capacity: 8, delta: 15)]
    
    var talonGroups = [
        LinearGroup(id: "Talon0", capacity: 2, delta: 10),
        LinearGroup(id: "Talon1", capacity: 2, delta: 10),
        LinearGroup(id: "Talon2", capacity: 2, delta: 10),
        LinearGroup(id: "Talon3", capacity: 2, delta: 10)]
    
    var winGroups = [
        CardGroup(id: "Win0"),
        CardGroup(id: "Win1")]
    
    init(json: JSON)
    {
        initialGroup = CardGroup(json: json["initial_group"])
        centerGroup = CenterGroup(json: json["center_group"])
        handGroups = json["hand_groups"].arrayValue.map({ (json) -> LinearGroup in
            return LinearGroup(json: json)
        })
        talonGroups = json["talon_groups"].arrayValue.map({ (json) -> LinearGroup in
            return LinearGroup(json: json)
        })
        winGroups = json["win_groups"].arrayValue.map({ (json) -> CardGroup in
            return CardGroup(json: json)
        })
    }
}

extension Bela: CardGame {
    func groups() -> [CardGroup] {
        var result = [initialGroup,centerGroup]
        result.append(contentsOf: handGroups)
        result.append(contentsOf: talonGroups)
        result.append(contentsOf: winGroups)
        return result
    }
    
    func group(by id: String) -> CardGroup? {
        return groups().first(where: { (group) -> Bool in
            return group.id == id
        })
    }
    
    func idxOfPlayerOnTurn() -> Int {
        return indexOfPlayerOnTurn
    }
}
