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

class CardGroup {
    var pos = CGPoint.zero
    var zRotation = CGFloat(0)
    var zPosition = CGFloat(0)
    var scale = CGFloat(1)
    
    var cards = [Card]()
    
    func position(at idx: Int) -> CGPoint {
        return pos
    }
    func zPosition(at idx: Int) -> CGFloat {
        return CGFloat(idx)*0.01
    }
    func zRotation(at idx:Int) -> CGFloat {
        return zRotation
    }
    
    func setNodePlacement(node: SKNode) {
        pos = node.position
        zPosition = node.zPosition
        zRotation = node.zRotation
    }

}

class LinearGroup: CardGroup
{
    var capacity:Int
    var delta:CGFloat
    var dir = CGVector(dx: 1, dy: 0)
    
    init(capacity:Int,delta:CGFloat) {
        self.capacity = capacity
        self.delta = delta
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

