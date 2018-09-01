//
//  CardGroup.swift
//  karte
//
//  Created by Kresimir Prcela on 12/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation
import CoreGraphics
import SceneKit
import SwiftyJSON

enum CardGroupVisibility: Int {
    case Hidden = 0
    case VisibleToLocalOnly
    case Visible
}

fileprivate let cardDepth: Float = 0.06

class CardGroup {
    var id: String
    var visibility: CardGroupVisibility
    
    var pos = SCNVector3Zero
    var eulerAngles = SCNVector3Zero // radians
    var scale = SCNVector3(1, 1, 1)
    
    var cards = [Card]()
    
    init(id: String) {
        self.id = id
        self.visibility = .Hidden
    }
    
    init(json: JSON) {
        id = json["id"].stringValue
        visibility = CardGroupVisibility(rawValue: json["visibility"].intValue)!
        cards = json["cards"].arrayValue.map({ (json) -> Card in
            return Card(json: json)
        })
    }
    
    func position(for card: Card) -> SCNVector3 {
        var p = SCNVector3Zero
        if let idx = cards.index(of: card) {
            p.z -= Float(idx)*cardDepth
        }
        return p
    }
    
    func eulerAngles(for card:Card) -> SCNVector3 {
        return SCNVector3Zero
    }
    
    func setNodePlacement(node: SCNNode) {
        pos = node.position
        eulerAngles = node.eulerAngles
        scale = node.scale
    }
    
    func card(name: String) -> Card? {
        return cards.first(where: { (card) -> Bool in
            return card.nodeName() == name
        })
    }

}

class LinearGroup: CardGroup
{
    var delta:Float
    
    init(id: String, delta:Float) {
        self.delta = delta
        super.init(id: id)
    }
    
    override init(json: JSON) {
        delta = 4
        super.init(json: json)
    }
    
    
    override func position(for card: Card) -> SCNVector3 {
        if let idx = cards.index(of: card) {
            let x = -(Float(cards.count)/2-0.5)*delta + Float(idx)*delta
            return SCNVector3(x:x, y: 0, z:0)
        }
        return SCNVector3Zero
    }
}

class HandGroup: LinearGroup
{
    override func position(for card: Card) -> SCNVector3 {
        var cardPos = super.position(for: card)
        if let idx = cards.index(of: card) {
            cardPos.z = Float(idx)*cardDepth
            cardPos.y = -abs(Float(cardPos.x))/8
        }
        return cardPos
    }
    
    override func eulerAngles(for card: Card) -> SCNVector3 {
        var angles = SCNVector3Zero
        if let idx = cards.index(of: card) {
            angles.z = (Float(cards.count)/2-Float(idx))*Float.pi/36
        }
        return angles
    }
}
