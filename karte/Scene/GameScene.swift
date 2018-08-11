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
    
    var localPlayerIdx: Int = 0 {
        didSet {
            print("Local player index: \(localPlayerIdx)")
        }
    }
    var enabledMoves = [Int:[CardEnabledMove]]() {
        didSet {
            if let localMoves = enabledMoves[localPlayerIdx] {
                for move in localMoves {
                    if let node = childNode(withName: move.card.nodeName()) {
                        let actionScale = SKAction.scale(to: 1.2, duration: 0.2)
                        node.run(actionScale)
                    }
                }
            }
            for (idx,lblNode) in playersLbls.enumerated() {
                if let _ = enabledMoves[idx] {
                    lblNode.color = UIColor.white
                    lblNode.fontName = UIFont.systemFont(ofSize: 14, weight: .bold).fontName
                } else {
                    lblNode.color = UIColor.white.withAlphaComponent(0.5)
                    lblNode.fontName = UIFont.systemFont(ofSize: 14, weight: .thin).fontName
                }
            }
        }
    }
    
    var playersLbls = [SKLabelNode]()
    
    override func didMove(to view: SKView) {
        
        playersLbls.removeAll()
        for idx in 0...3 {
            let hNode = childNode(withName: "H\(idx)")
            let cNode = childNode(withName: "C\(idx)")
            let lblNode = childNode(withName: "P\(idx)") as! SKLabelNode
            let absIdx = (idx+localPlayerIdx)%4
            hNode?.name = "Hand\(absIdx)"
            cNode?.name = "Center\(absIdx)"
            lblNode.name = "Player\(absIdx)"
            lblNode.text = "Player \(absIdx)"
            playersLbls.append(lblNode)
        }
        playersLbls.sort { return $0.name! < $1.name! }
        refreshPlayersAliases()
        
        // testPreview()
    }
    
    func refreshPlayersAliases()
    {
        if let tableId = PlayerStat.shared.tableId,
            let table = Room.shared.tablesInfo[tableId]
        {
            for idx in 0..<table.capacity {
                var alias = "?"
                if idx < table.playersId.count {
                    let playerId = table.playersId[idx]
                    if let p = Room.shared.playersInfo[playerId] {
                        alias = p.alias
                    }
                }
                playersLbls[idx].text = alias
            }
        }
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
            
            for card in group.cards
            {
                let cardW = size.width * 0.15
                let cardNode = CardNode(card: card,width: cardW)
                cardNode.zPosition = group.zPosition(for: card)
                cardNode.position = group.position(for: card)
                cardNode.zRotation = group.zRotation(for: card)
                cardNode.frontNode?.isHidden = !visible
                cardNode.backNode?.isHidden = visible
                cardNode.setScale(group.scale)
                addChild(cardNode)
            }
            
        }
    }
    
    
    
    @discardableResult
    func move(card: Card, fromGroup: CardGroup, toGroup: CardGroup, toTop: Bool, waitDuration:Double, duration: Double) -> Bool {
        guard let fromIdx = fromGroup.cards.index(where: { (c) -> Bool in
            return c == card
        }) else {
            return false
        }
        
        fromGroup.cards.remove(at: fromIdx)
        if toTop {
            toGroup.cards.append(card)
        } else {
            toGroup.cards.insert(card, at: 0)
        }
        
        if toGroup.id.hasPrefix("Center"),
            let groups = sharedGame?.groups()
        {
            var sum = 0
            for cg in groups.filter({ (group) -> Bool in
                return group.id.hasPrefix("Center")
            }) {
                sum += cg.cards.count
            }
            toGroup.zPosition = CGFloat(sum)*0.1
        }
        
        let duration = 0.5
        for card in toGroup.cards {
            let actionPos = SKAction.move(to: toGroup.position(for: card), duration: duration)
            let actionRot = SKAction.rotate(toAngle: toGroup.zRotation(for: card), duration: duration, shortestUnitArc: true)
            let actionScale = SKAction.scale(to: toGroup.scale, duration: duration)
            let cardNode = self.childNode(withName: card.nodeName()) as! CardNode
            
            let actionWait = SKAction.wait(forDuration: waitDuration)
            let actionGroup = SKAction.group([actionPos,actionRot,actionScale])
            let actionSequence = SKAction.sequence([actionWait,actionGroup])
            
            DispatchQueue.main.asyncAfter(deadline: .now()+waitDuration+0.5*duration) {
                cardNode.zPosition = toGroup.zPosition(for: card)
            }
        
            if toGroup.visibility == .Visible {
                cardNode.backNode?.isHidden = true
                cardNode.frontNode?.isHidden = false
            }
            
            cardNode.run(actionSequence) {
                let visible = toGroup.visibility == .Visible || (toGroup.visibility == .VisibleToLocalOnly && toGroup.id.hasSuffix("\(self.localPlayerIdx)"))
                cardNode.backNode?.isHidden = visible
                cardNode.frontNode?.isHidden = !visible
            }
        }
        return true
    }
    
    @discardableResult
    func moveCard(cardName: String, toGroup: CardGroup, waitDuration:Double, duration: Double) -> Bool
    {
        var card: Card?
        if let group = sharedGame?.groups().first(where: { (group) -> Bool in
            card = group.card(name: cardName)
            return card != nil
        }) {
            return move(card: card!, fromGroup: group, toGroup: toGroup, toTop: true, waitDuration: waitDuration, duration: duration)
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
        if let touchedCardNode = cardNodes.first(where: { (card) -> Bool in
            return card.contains(pos)
        }),
            let playerEnabledMoves = enabledMoves[localPlayerIdx],
            let enabledMove = playerEnabledMoves.first(where: { (enabledMove) -> Bool in
                return enabledMove.card.nodeName() == touchedCardNode.name
            })
        {
            if let toGroupId = enabledMove.toGroupId,
                let toGroup = sharedGame?.group(by: toGroupId)
            {
                moveCard(cardName: enabledMove.card.nodeName(), toGroup: toGroup, waitDuration: 0, duration: 0.5)
            }
            
            WsAPI.shared.send(.Turn, json: JSON(["turn":"tap_card", "enabled_move":enabledMove.dictionary()]))
            
            if let fromGroup = sharedGame?.group(by: enabledMove.fromGroupId) {
                for enabledMove in playerEnabledMoves {
                    if let cn = cardNodes.first(where: { (cardNode) -> Bool in
                        return cardNode.name == enabledMove.card.nodeName()
                    }), cn != touchedCardNode {
                        let actionScale = SKAction.scale(to: fromGroup.scale, duration: 0.5)
                        cn.run(actionScale)
                    }
                }
            }
            
            enabledMoves[localPlayerIdx]?.removeAll()
        }
    }
    
    
    
    func onTransitions(transitions: [CardTransition], onFinished: @escaping () -> Void) {
        var totalDuration:TimeInterval = 0
        
        for t in transitions {
            if let fromGroup = sharedGame?.group(by: t.fromGroupId),
                let toGroup = sharedGame?.group(by: t.toGroupId) {
                move(card: t.card,
                     fromGroup: fromGroup,
                     toGroup: toGroup,
                     toTop: t.toTop,
                     waitDuration: t.waitDuration,
                     duration: t.duration)
                totalDuration = max(totalDuration, t.waitDuration + t.duration)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+totalDuration) {
            onFinished()
        }
    }
    
    
    
    func testPreview()
    {
    }
}
