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
    let handGroup0 = LinearGroup(capacity: 8, delta: 35)
    let handGroup1 = LinearGroup(capacity: 8, delta: 15)
    let handGroup2 = LinearGroup(capacity: 8, delta: 20)
    let handGroup3 = LinearGroup(capacity: 8, delta: 15)
    
    let talon0 = LinearGroup(capacity: 2, delta: 10)
    let talon1 = LinearGroup(capacity: 2, delta: 10)
    let talon2 = LinearGroup(capacity: 2, delta: 10)
    let talon3 = LinearGroup(capacity: 2, delta: 10)
    
    let talonGroup0 = CardGroup()
    
    override func didMove(to view: SKView) {
        
        // move all cards to initial group
        let nodeInitial = self.childNode(withName: "//Initial")!
        initialGroup.setNodePlacement(node: nodeInitial)
        for group in [initialGroup,handGroup1,handGroup2,handGroup3,talon0,talon1,talon2,talon3] {
            group.scale = 0.72
        }
        
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
            cardNode.backNode?.isHidden = false
            cardNode.frontNode?.isHidden = true
            cardNode.setScale(initialGroup.scale)
            addChild(cardNode)
        }
        
        
        for (idx,group) in [handGroup0,handGroup1,handGroup2,handGroup3].enumerated() {
            let lblNode = self.childNode(withName: "//PlayerPlus\(idx)") as! SKLabelNode
            lblNode.text = "Player \(idx)"
            group.setNodePlacement(node: lblNode)
        }
        
        for (idx,talon) in [talon0,talon1,talon2,talon3].enumerated() {
            let nodeTalon = childNode(withName: "//Talon\(idx)")!
            talon.setNodePlacement(node: nodeTalon)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            for (idxGroup,group) in [self.handGroup0,self.handGroup1,self.handGroup2,self.handGroup3,self.talon0,self.talon1,self.talon2,self.talon3].enumerated() {
                let ctInGroup = group.capacity == 2 ? 2:6
                for idx in 0..<ctInGroup {
                    self.moveCard(fromGroup: self.initialGroup,
                                  toGroup: group,
                                  idx: idx,
                                  waitDuration: 0.2*Double(idx)+1.2*Double(idxGroup),
                                  duration: 0.5)
                }
            }
        }
    }
    
    @discardableResult
    func moveCard(fromGroup: CardGroup, toGroup: CardGroup, idx: Int, waitDuration:Double, duration: Double) -> Bool {
        let card = fromGroup.cards.popLast()!
        toGroup.cards.append(card)
        let duration = 0.5
        let actionPos = SKAction.move(to: toGroup.position(at: idx), duration: duration)
        let actionRot = SKAction.rotate(toAngle: toGroup.zRotation, duration: duration, shortestUnitArc: true)
        let actionScale = SKAction.scale(to: toGroup.scale, duration: duration)
        let cardNode = self.childNode(withName: card.nodeName()) as! CardNode
        
        let actionWait = SKAction.wait(forDuration: waitDuration)
        let actionGroup = SKAction.group([actionPos,actionRot,actionScale])
        let actionSequence = SKAction.sequence([actionWait,actionGroup])
        cardNode.run(actionSequence) {
            cardNode.zPosition = toGroup.zPosition(at: idx)
            
            if toGroup === self.handGroup0 {
                cardNode.backNode?.isHidden = true
                cardNode.frontNode?.isHidden = false
            } else {
                cardNode.backNode?.isHidden = false
                cardNode.frontNode?.isHidden = true
            }
        }
        return true
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
