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
    
    var cards = [Card]()
    
    func position(at idx: Int) -> CGPoint {
        return pos
    }
    func zPosition(at idx: Int) -> CGFloat {
        return CGFloat(idx)*0.01
    }
    func zRotation(at idx:Int) -> CGFloat {
        return 1
    }
    
    func setNodePlacement(node: SKNode) {
        pos = node.position
        zPosition = node.zPosition
        zRotation = node.zRotation
    }

}

class PlayerHandGroup: CardGroup
{
    var dir = CGVector(dx: 1, dy: 0)
    override func position(at idx: Int) -> CGPoint {
        let delta:CGFloat = 35
        return CGPoint(x: pos.x - 3.5*delta*dir.dx + CGFloat(idx)*delta*dir.dx, y: pos.y - 3.5*delta*dir.dy + CGFloat(idx)*delta*dir.dy)
    }
    
    override func setNodePlacement(node: SKNode) {
        super.setNodePlacement(node: node)
        let eps:CGFloat = 0.001
        if zRotation == 0 {
            dir = CGVector(dx: 1, dy: 0)
        } else if zRotation > CGFloat.pi/2-eps && zRotation < CGFloat.pi/2+eps {
            dir = CGVector(dx: 0, dy: 0.5)
        } else if zRotation > CGFloat.pi-eps && zRotation < CGFloat.pi+eps {
            dir = CGVector(dx: -1, dy: 0)
        } else if zRotation > 1.5*CGFloat.pi-eps && zRotation < 1.5*CGFloat.pi+eps {
            dir = CGVector(dx: 0, dy: -0.5)
        }
    }
}
