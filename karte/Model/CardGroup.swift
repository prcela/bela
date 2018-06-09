//
//  CardGroup.swift
//  karte
//
//  Created by Kresimir Prcela on 12/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation
import CoreGraphics
import SpriteKit
import SwiftyJSON

enum CardGroupVisibility: Int {
    case Hidden = 0
    case VisibleToLocalOnly
    case Visible
}

class CardGroup {
    var id: String
    var visibility: CardGroupVisibility
    
    var pos = CGPoint.zero
    var zRotation = CGFloat(0)
    var zPosition = CGFloat(0)
    var scale = CGFloat(1)
    
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
    
    func position(for card: Card) -> CGPoint {
        return pos
    }
    func zPosition(for card: Card) -> CGFloat {
        if let idx = cards.index(of: card) {
            return zPosition + CGFloat(idx+1)*0.01
        }
        return 0.01
    }
    func zRotation(for card:Card) -> CGFloat {
        return zRotation
    }
    
    func setNodePlacement(node: SKNode) {
        pos = node.position
        zPosition = node.zPosition
        zRotation = node.zRotation
        scale = (node.xScale+node.yScale)/2
    }

}

class LinearGroup: CardGroup
{
    var delta:CGFloat
    var dir = CGVector(dx: 1, dy: 0)
    
    init(id: String, delta:CGFloat) {
        self.delta = delta
        super.init(id: id)
    }
    
    override init(json: JSON) {
        delta = 15
        super.init(json: json)
    }
    
    
    override func position(for card: Card) -> CGPoint {
        if let idx = cards.index(of: card) {
            return CGPoint(x: pos.x - (CGFloat(cards.count/2)-0.5)*delta*dir.dx + CGFloat(idx)*delta*dir.dx, y: pos.y - (CGFloat(cards.count/2)-0.5)*delta*dir.dy + CGFloat(idx)*delta*dir.dy)
        }
        return CGPoint.zero
    }
    
    override func setNodePlacement(node: SKNode) {
        super.setNodePlacement(node: node)
        dir.dx = cos(zRotation)
        dir.dy = sin(zRotation)
    }
}


