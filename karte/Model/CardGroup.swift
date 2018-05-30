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
    
    func position(at idx: Int) -> CGPoint {
        return pos
    }
    func zPosition(at idx: Int) -> CGFloat {
        return CGFloat(idx+1)*0.01
    }
    func zRotation(at idx:Int) -> CGFloat {
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
    var capacity:Int
    var delta:CGFloat
    var dir = CGVector(dx: 1, dy: 0)
    
    init(id: String, capacity:Int, delta:CGFloat) {
        self.capacity = capacity
        self.delta = delta
        super.init(id: id)
    }
    
    override init(json: JSON) {
        capacity = json["capacity"].intValue
        delta = 15
        super.init(json: json)
    }
    
    
    override func position(at idx: Int) -> CGPoint { 
        return CGPoint(x: pos.x - (CGFloat(capacity/2)-0.5)*delta*dir.dx + CGFloat(idx)*delta*dir.dx, y: pos.y - (CGFloat(capacity/2)-0.5)*delta*dir.dy + CGFloat(idx)*delta*dir.dy)
    }
    
    override func setNodePlacement(node: SKNode) {
        super.setNodePlacement(node: node)
        dir.dx = cos(zRotation)
        dir.dy = sin(zRotation)
    }
}

class CenterGroup: CardGroup {
    
    override init(id: String) {
        super.init(id: id)
    }
    
    override init(json: JSON) {
        super.init(json: json)
    }
    
    override func position(at idx: Int) -> CGPoint {
        let pos = super.position(at: idx)
        var rot = zRotation
        let rightDir = CGVector(dx: cos(rot), dy: sin(rot))
        rot += 0.5*CGFloat.pi
        let updir = CGVector(dx: cos(rot), dy: sin(rot))
        return CGPoint(x: pos.x-30*updir.dx-15*rightDir.dx, y: pos.y-30*updir.dy-15*rightDir.dy)
    }
}

