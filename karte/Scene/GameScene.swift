//
//  GameScene.swift
//  karte
//
//  Created by Kresimir Prcela on 12/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation
import SpriteKit
import SwiftyJSON

class GameScene: SKScene {
    
    var localPlayerIdx: Int = 0
    var enabledMoves = [Int:[CardEnabledMove]]()
    var playersLbls = [SKLabelNode]()
    
    fileprivate func refreshPlayersAliases()
    {
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
    }
    
    override func didMove(to view: SKView) {
        
        playersLbls.removeAll()
        for idx in 0...3 {
            let hNode = childNode(withName: "H\(idx)")
            hNode?.name = "Hand\((idx+localPlayerIdx)%4)"
            let idx = (idx+4-localPlayerIdx)%4
            let lblNode = childNode(withName: "//PlayerPlus\(idx)") as! SKLabelNode
            lblNode.text = "Player \(idx)"
            
            playersLbls.append(lblNode)
        }
        refreshPlayersAliases()
        
        // testPreview()
    }
    
    func onGame(cardGame: CardGame)
    {
        for group in cardGame.groups()
        {
            let groupNode = childNode(withName: group.id)!
            group.setNodePlacement(node: groupNode)
            
            if group.id == "Hand\(localPlayerIdx)" {
                (group as! LinearGroup).delta = 30
            }
            
            let visible = group.visibility == .Visible || (group.visibility == .VisibleToLocalOnly && group.id.hasSuffix("\(localPlayerIdx)"))
            
            for (idx,card) in group.cards.enumerated()
            {
                let cardW = size.width * 0.15
                let cardNode = CardNode(card: card,width: cardW)
                cardNode.zPosition = group.zPosition(at: idx)
                cardNode.position = group.position(at: idx)
                cardNode.zRotation = group.zRotation(at: idx)
                cardNode.frontNode?.isHidden = !visible
                cardNode.backNode?.isHidden = visible
                cardNode.setScale(group.scale)
                addChild(cardNode)
            }
            
        }
    }
    
    
    
    @discardableResult
    func move(card: Card, fromGroup: CardGroup, toGroup: CardGroup, toIdx: Int, waitDuration:Double, duration: Double) -> Bool {
        if let fromIdx = fromGroup.cards.index(where: { (c) -> Bool in
            return c == card
        }) {
            fromGroup.cards.remove(at: fromIdx)
        }
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
        
        
        if toGroup.id == "Center" {
            cardNode.backNode?.isHidden = true
            cardNode.frontNode?.isHidden = false
        }
        
        cardNode.run(actionSequence) {
            
            if toGroup.id == "Hand\(self.localPlayerIdx)" || toGroup.id == "Center" {
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
        var card: Card?
        if let group = sharedGame.groups().first(where: { (group) -> Bool in
            return group.cards.contains(where: { (c) -> Bool in
                if c.nodeName() == cardName {
                    card = c
                    return true
                }
                return false
            })
        }) {
            return move(card: card!, fromGroup: group, toGroup: toGroup, toIdx: toGroup.cards.count, waitDuration: waitDuration, duration: duration)
        }
        return false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touchUp(atPoint: t.location(in: self))
        }
    }
    
    fileprivate func touchUp(atPoint pos : CGPoint) {
        var cardNodes = [CardNode]()
        enumerateChildNodes(withName: "card_*") { (card, _) in
            cardNodes.append(card as! CardNode)
        }
        // sort from top to bottom
        cardNodes.sort { (card0, card1) -> Bool in
            return card0.zPosition > card1.zPosition
        }
        if let cardNode = cardNodes.first(where: { (card) -> Bool in
            return card.contains(pos)
        }),
            let playerEnabledMoves = enabledMoves[localPlayerIdx],
            let enabledMove = playerEnabledMoves.first(where: { (enabledMove) -> Bool in
                return enabledMove.card.nodeName() == cardNode.name
            })
        {
            if let toGroupId = enabledMove.toGroupId,
                let toGroup = sharedGame.group(by: toGroupId) {
                moveCard(cardName: enabledMove.card.nodeName(), toGroup: toGroup, waitDuration: 0, duration: 0.5)
            }
            
            WsAPI.shared.send(.Turn, json: JSON(["turn":"tap_card", "enabled_move":enabledMove.dictionary()]))
            enabledMoves[localPlayerIdx]?.removeAll()
            
            // centerGroup.zRotation = cardNode.zRotation
            // moveCard(cardName: cardNode.name!, toGroup: centerGroup, waitDuration: 0, duration: 0.5)
            
            // if centerGroup.cards.count == 4 {
            //    for _ in centerGroup.cards {
            //        moveCard(fromGroup: centerGroup, fromIdx: 0, toGroup: winGroup1, toIdx: winGroup1.cards.count, waitDuration: 2, duration: 0.3)
            //    }
        }
    }
    
    
    
    func onTransitions(transitions: [CardTransition], onFinished: @escaping () -> Void) {
        var totalDuration:TimeInterval = 0
        
        for t in transitions {
            if let fromGroup = sharedGame.group(by: t.fromGroupId),
                let toGroup = sharedGame.group(by: t.toGroupId) {
                move(card: t.card,
                     fromGroup: fromGroup,
                     toGroup: toGroup,
                     toIdx: t.toIdx,
                     waitDuration: t.waitDuration,
                     duration: t.duration)
                totalDuration = max(totalDuration, t.waitDuration + t.duration)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+totalDuration) {
            onFinished()
        }
    }
    
    func onPlayerJoined(_ joinedPlayerId: String)
    {
        refreshPlayersAliases()
    }
    
    func testPreview()
    {
    }
}
