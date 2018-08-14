//
//  Bela.swift
//  karte
//
//  Created by Kresimir Prcela on 27/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation
import SwiftyJSON
import SpriteKit

enum GameState: Int {
    case Init        = 0
    case Dealed      = 1
    case Call        = 2
    case PickedTalon = 3
    case Play        = 4
}

class Bela
{
    var state: GameState = .Init
    var indexOfPlayerOnTurn = 0
    var idxPlayerCalled: Int?
    var adut: Boja?
    var initialGroup = CardGroup(id: "Initial")
    var handGroups = [
        LinearGroup(id: "Hand0", delta: 15),
        LinearGroup(id: "Hand1", delta: 15),
        LinearGroup(id: "Hand2", delta: 15),
        LinearGroup(id: "Hand3", delta: 15)]
    
    var talonGroups = [
        LinearGroup(id: "Talon0",  delta: 10),
        LinearGroup(id: "Talon1",  delta: 10),
        LinearGroup(id: "Talon2",  delta: 10),
        LinearGroup(id: "Talon3",  delta: 10)]
    
    var winGroups = [
        CardGroup(id: "Win0"),
        CardGroup(id: "Win1")]
    
    var centerGroups = [
        CardGroup(id: "Center0"),
        CardGroup(id: "Center1"),
        CardGroup(id: "Center2"),
        CardGroup(id: "Center3")]
    
    init(json: JSON)
    {
        initialGroup = CardGroup(json: json["initial_group"])
        centerGroups = json["center_groups"].arrayValue.map({ (json) -> CardGroup in
            return CardGroup(json: json)
        })
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
        var result = [initialGroup]
        result.append(contentsOf: handGroups)
        result.append(contentsOf: talonGroups)
        result.append(contentsOf: winGroups)
        result.append(contentsOf: centerGroups)
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
    
    func onEvent(event: GameEvent, scene: GameScene) {
        switch event.category {
        case "Player":
            switch event.action {
            case "Call":
                adut = Boja(rawValue: event.label)
                idxPlayerCalled = event.value
                let tex = SKTexture(imageNamed: event.label)
                let callNode = SKSpriteNode(texture: tex, size: CGSize(width:40,height:40))
                let playerNameLbl = scene.playersLbls[idxPlayerCalled!]
                callNode.position = playerNameLbl.position
                callNode.zRotation = playerNameLbl.zRotation
                callNode.name = "Adut"
                scene.addChild(callNode)
            default:
                break
            }
            
        case "Game":
            switch event.action {
            case "ChangedIdxPlayerOnTurn":
                indexOfPlayerOnTurn = event.value
            default:
                break
            }
        default:
            break
        }
    }
    
}
