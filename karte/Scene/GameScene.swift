//
//  GameScene.swift
//  karte
//
//  Created by Kresimir Prcela on 12/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation
import SpriteKit

class GameScene: SKScene {
    
    let initialGroup = CardGroup()
    let handGroup0 = PlayerHandGroup()
    let handGroup1 = PlayerHandGroup()
    let handGroup2 = PlayerHandGroup()
    let handGroup3 = PlayerHandGroup()
    
    override func didMove(to view: SKView) {
        
        // move all cards to initial group
        initialGroup.pos = CGPoint(x: -50, y: 10)
        initialGroup.zRotation = 1
        for boja in [Boja.bundeva,Boja.list,Boja.srce,Boja.žir] {
            for broj in [Broj.vii,Broj.viii,Broj.ix,Broj.x,Broj.dečko,Broj.dama,Broj.kralj,Broj.kec] {
                initialGroup.cards.append(Card(boja: boja, broj: broj))
            }
        }
        
        for (idx,card) in initialGroup.cards.enumerated()
        {
            let cardW = size.width * 0.15
            let cardNode = CardNode(card: card,width: cardW)
            cardNode.zPosition = initialGroup.zPosition(at: idx)
            cardNode.position = initialGroup.position(at: idx)
            cardNode.zRotation = initialGroup.zRotation(at: idx)
            addChild(cardNode)
        }
        
        
        let nodeP0 = self.childNode(withName: "//PlayerPlus0")!
        handGroup0.setNodePlacement(node: nodeP0)
        
        let nodeP1 = self.childNode(withName: "//PlayerPlus1")!
        handGroup1.setNodePlacement(node: nodeP1)
        
        let nodeP2 = self.childNode(withName: "//PlayerPlus2")!
        handGroup2.setNodePlacement(node: nodeP2)
        
        let nodeP3 = self.childNode(withName: "//PlayerPlus3")!
        handGroup3.setNodePlacement(node: nodeP3)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            for group in [self.handGroup0,self.handGroup1,self.handGroup2,self.handGroup3] {
                for idx in 0...7 {
                    let card = self.initialGroup.cards.popLast()!
                    group.cards.append(card)
                    let duration = 0.5
                    let actionPos = SKAction.move(to: group.position(at: idx), duration: duration)
                    let actionRot = SKAction.rotate(toAngle: group.zRotation, duration: duration, shortestUnitArc: true)
                    let cardNode = self.childNode(withName: card.nodeName())!
                    cardNode.zPosition = group.zPosition(at: idx)
                    
                    cardNode.run(actionPos)
                    cardNode.run(actionRot)
                }
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touchUp(atPoint: t.location(in: self))
        }
    }
    
    fileprivate func touchUp(atPoint pos : CGPoint) {
        var cards = [SKCropNode]()
        enumerateChildNodes(withName: "card") { (card, _) in
            cards.append(card as! SKCropNode)
        }
        // sort from top to bottom
        cards.sort { (card0, card1) -> Bool in
            return card0.zPosition > card1.zPosition
        }
        if let card = cards.first(where: { (card) -> Bool in
            return card.contains(pos)
        }) {
            let duration = 0.5
            let actionPos = SKAction.move(to: handGroup0.position(at: 0), duration: duration)
            let actionRot = SKAction.rotate(toAngle: handGroup0.zRotation, duration: duration, shortestUnitArc: true)
            card.run(actionPos)
            card.run(actionRot)
        }
    }
}
