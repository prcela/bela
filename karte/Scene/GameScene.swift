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
    
    var localPlayerIdx: Int = 0
    
    let initialGroup = CardGroup(id: "Initial")
    let handGroup0 = LinearGroup(id: "Hand0", capacity: 8, delta: 35)
    let handGroup1 = LinearGroup(id: "Hand1", capacity: 8, delta: 15)
    let handGroup2 = LinearGroup(id: "Hand2", capacity: 8, delta: 20)
    let handGroup3 = LinearGroup(id: "Hand3", capacity: 8, delta: 15)
    
    let talonGroup0 = LinearGroup(id: "Talon0", capacity: 2, delta: 10)
    let talonGroup1 = LinearGroup(id: "Talon1", capacity: 2, delta: 10)
    let talonGroup2 = LinearGroup(id: "Talon2", capacity: 2, delta: 10)
    let talonGroup3 = LinearGroup(id: "Talon3", capacity: 2, delta: 10)
    
    let centerGroup = CenterGroup(id: "Center")
    
    let winGroup0 = CardGroup(id: "Win0")
    let winGroup1 = CardGroup(id: "Win1")
    
    var playersLbls = [SKLabelNode]()
    
    override func didMove(to view: SKView) {
        
        // move all cards to initial group
        let nodeInitial = self.childNode(withName: "//Initial")!
        initialGroup.setNodePlacement(node: nodeInitial)
        for group in [initialGroup,handGroup1,handGroup2,handGroup3,talonGroup0,talonGroup1,talonGroup2,talonGroup3] {
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
        
        playersLbls.removeAll()
        for (idx,group) in [handGroup0,handGroup1,handGroup2,handGroup3].enumerated() {
            let idx = (idx+4-localPlayerIdx)%4
            let node = childNode(withName: "//PlayerPos\(idx)")!
            let lblNode = childNode(withName: "//PlayerPlus\(idx)") as! SKLabelNode
            lblNode.text = "Player \(idx)"
            group.setNodePlacement(node: node)
            playersLbls.append(lblNode)
        }
        
        let nodeCenter = childNode(withName: "//Center")!
        centerGroup.setNodePlacement(node: nodeCenter)
        centerGroup.scale = 0.85
        
        for (idx,talon) in [talonGroup0,talonGroup1,talonGroup2,talonGroup3].enumerated() {
            let idx = (idx+4-localPlayerIdx)%4
            let nodeTalon = childNode(withName: "//Talon\(idx)")!
            talon.setNodePlacement(node: nodeTalon)
        }
        
        for (idx,group) in [winGroup0,winGroup1].enumerated() {
            let node = childNode(withName: "//Win\(idx)")!
            group.setNodePlacement(node: node)
        }
        
        if let tableId = PlayerStat.shared.tableId,
            let table = Room.shared.tablesInfo[tableId]
        {
            for idx in 0..<table.capacity {
                let idx = (idx+4-localPlayerIdx)%4
                if idx < table.playersId.count {
                    let playerId = table.playersId[idx]
                    let p = Room.shared.playersInfo[playerId]
                    playersLbls[idx].text = p?.alias
                } else {
                    playersLbls[idx].text = "?"
                }
            }
        }
        
        // testPreview()
    }
    
    @discardableResult
    func moveCard(fromGroup: CardGroup, fromIdx: Int, toGroup: CardGroup, toIdx: Int, waitDuration:Double, duration: Double) -> Bool {
        let card = fromGroup.cards.remove(at: fromIdx)
        toGroup.cards.insert(card, at: toIdx)
        let duration = 0.5
        let actionPos = SKAction.move(to: toGroup.position(at: toIdx), duration: duration)
        let actionRot = SKAction.rotate(toAngle: toGroup.zRotation(at: toIdx), duration: duration, shortestUnitArc: true)
        let actionScale = SKAction.scale(to: toGroup.scale, duration: duration)
        let cardNode = self.childNode(withName: card.nodeName()) as! CardNode
        
        let actionWait = SKAction.wait(forDuration: waitDuration)
        let actionGroup = SKAction.group([actionPos,actionRot,actionScale])
        let actionSequence = SKAction.sequence([actionWait,actionGroup])
        
        DispatchQueue.main.asyncAfter(deadline: .now()+waitDuration+0.5*duration) {
            cardNode.zPosition = toGroup.zPosition(at: toIdx)
        }
        
        
        if toGroup === self.centerGroup {
            cardNode.backNode?.isHidden = true
            cardNode.frontNode?.isHidden = false
        }
        
        let myHandGroup = group(by: "Hand\(localPlayerIdx)")!
        
        cardNode.run(actionSequence) {
            
            if toGroup === myHandGroup || toGroup === self.centerGroup {
                cardNode.backNode?.isHidden = true
                cardNode.frontNode?.isHidden = false
            } else {
                cardNode.backNode?.isHidden = false
                cardNode.frontNode?.isHidden = true
            }
        }
        return true
    }
    
    @discardableResult
    func moveCard(cardName: String, toGroup: CardGroup, waitDuration:Double, duration: Double) -> Bool
    {
        var idxFound: Int?
        if let group = [initialGroup,handGroup0,handGroup1,handGroup2,handGroup3,talonGroup0,talonGroup1,talonGroup2,talonGroup3].first(where: { (group) -> Bool in
            idxFound = group.cards.index(where: { (card) -> Bool in
                return card.nodeName() == cardName
            })
            return idxFound != nil
        }) {
            return moveCard(fromGroup: group, fromIdx: idxFound!, toGroup: toGroup, toIdx: toGroup.cards.count, waitDuration: waitDuration, duration: duration)
        }
        return false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touchUp(atPoint: t.location(in: self))
        }
    }
    
    fileprivate func touchUp(atPoint pos : CGPoint) {
        var cards = [CardNode]()
        enumerateChildNodes(withName: "card_*") { (card, _) in
            cards.append(card as! CardNode)
        }
        // sort from top to bottom
        cards.sort { (card0, card1) -> Bool in
            return card0.zPosition > card1.zPosition
        }
        if let card = cards.first(where: { (card) -> Bool in
            return card.contains(pos)
        }) {
            centerGroup.zRotation = card.zRotation
            moveCard(cardName: card.name!, toGroup: centerGroup, waitDuration: 0, duration: 0.5)
            
            if centerGroup.cards.count == 4 {
                for _ in centerGroup.cards {
                    moveCard(fromGroup: centerGroup, fromIdx: 0, toGroup: winGroup1, toIdx: winGroup1.cards.count, waitDuration: 2, duration: 0.3)
                }
            }
        }
    }
    
    fileprivate func group(by id: String) -> CardGroup? {
        let allGroups = [initialGroup,handGroup0,handGroup1,handGroup2,handGroup3,talonGroup0,talonGroup1,talonGroup2,talonGroup3,centerGroup,winGroup0,winGroup1]
        return allGroups.first(where: { (group) -> Bool in
            return group.id == id
        })
    }
    
    func onTransitions(transitions: [CardTransition]) {
        for t in transitions {
            if let fromGroup = group(by: t.fromGroupId),
                let toGroup = group(by: t.toGroupId) {
                moveCard(fromGroup: fromGroup,
                         fromIdx: t.fromIdx,
                         toGroup: toGroup,
                         toIdx: t.toIdx,
                         waitDuration: t.waitDuration,
                         duration: t.duration)
            }
        }
    }
    
    func testPreview()
    {
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            for (idxGroup,group) in [self.handGroup0,self.handGroup1,self.handGroup2,self.handGroup3,self.talonGroup0,self.talonGroup1,self.talonGroup2,self.talonGroup3].enumerated() {
                let ctInGroup = group.capacity == 2 ? 2:6
                for idx in 0..<ctInGroup {
                    self.moveCard(fromGroup: self.initialGroup,
                                  fromIdx: self.initialGroup.cards.count-1,
                                  toGroup: group,
                                  toIdx: idx,
                                  waitDuration: 0.2*Double(idx)+1.2*Double(idxGroup),
                                  duration: 0.5)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+10) {
            let srcGroups = [self.talonGroup0,self.talonGroup1,self.talonGroup2,self.talonGroup3]
            let dstGroups = [self.self.handGroup0,self.handGroup1,self.handGroup2,self.handGroup3]
            
            for (idxGroup,srcGroup) in srcGroups.enumerated() {
                let dstGroup = dstGroups[idxGroup]
                for (idx,_) in srcGroup.cards.enumerated() {
                    self.moveCard(fromGroup: srcGroup, fromIdx: 0, toGroup: dstGroup, toIdx: 6+idx, waitDuration: 0.2*Double(idx)+0.4*Double(idxGroup), duration: 0.5)
                }
            }
        }
    }
}
