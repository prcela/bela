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

class SKGameScene: SKScene {
    
    var localPlayerIdx: Int = 0 {
        didSet {
            print("Local player index: \(localPlayerIdx)")
        }
    }
    var cardNodes = [CardNode]()
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
                    lblNode.fontColor = UIColor.yellow
                    lblNode.fontName = UIFont.systemFont(ofSize: 14, weight: .bold).fontName
                    
                } else {
                    lblNode.fontColor = UIColor.white
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
        playersLbls.forEach { (node) in
            node.removeAllChildren()
        }
        cardNodes.removeAll()
        for group in cardGame.groups()
        {
            let groupNode = childNode(withName: group.id)!
            group.setNodePlacement(node: groupNode)
            
            if group.id == "Hand\(localPlayerIdx)" {
                (group as! LinearGroup).delta = 35
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
                cardNodes.append(cardNode)
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
    
    fileprivate func touchedCardNode(touches: Set<UITouch>) -> CardNode? {
        
        // sort from top to bottom
        cardNodes.sort { (card0, card1) -> Bool in
            return card0.zPosition > card1.zPosition
        }
        for t in touches {
            
            if let touchedCardNode = cardNodes.first(where: { (card) -> Bool in
                let pos = t.location(in: card)
                return card.shapeNode!.frame.contains(pos)
            }) {
                return touchedCardNode
            }
        }
        return nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let playerEnabledMoves = enabledMoves[localPlayerIdx] else {return}
        
        if let touchedCardNode = touchedCardNode(touches: touches) {
            for enabledMove in playerEnabledMoves {
                if enabledMove.card.nodeName() == touchedCardNode.name {
                    let actionScale = SKAction.scale(to: 1.3, duration: 0.2)
                    touchedCardNode.run(actionScale)
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let playerEnabledMoves = enabledMoves[localPlayerIdx] else {return}
        
        let touchedCN = touchedCardNode(touches: touches)
        for enabledMove in playerEnabledMoves {
            if enabledMove.card.nodeName() == touchedCN?.name {
                let desiredScale: CGFloat = 1.3
                if touchedCN?.xScale != desiredScale {
                    let actionScale = SKAction.scale(to: desiredScale, duration: 0.1)
                    touchedCN?.run(actionScale)
                }
            } else {
                if let node = childNode(withName: enabledMove.card.nodeName()) {
                    let desiredScale: CGFloat = 1.2
                    if node.xScale != desiredScale {
                        let actionScale = SKAction.scale(to: desiredScale, duration: 0.1)
                        node.run(actionScale)
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchedCardNode = touchedCardNode(touches: touches) {
            touchUp(cardNode: touchedCardNode)
        }
    }
    
    fileprivate func touchUp(cardNode: CardNode) {
        
        guard let playerEnabledMoves = enabledMoves[localPlayerIdx],
            let enabledMove = playerEnabledMoves.first(where: { (enabledMove) -> Bool in
                return enabledMove.card.nodeName() == cardNode.name
            })
        else { return }
        
        if let toGroupId = enabledMove.toGroupId,
            let toGroup = sharedGame?.group(by: toGroupId)
        {
            moveCard(cardName: enabledMove.card.nodeName(), toGroup: toGroup, waitDuration: 0, duration: 0.5)
        }
        
        WsAPI.shared.send(.Turn, json: JSON(["turn":"tap_card", "enabled_move":enabledMove.dictionary()]))
        
        // return all enabled cards to default group scale
        if let fromGroup = sharedGame?.group(by: enabledMove.fromGroupId) {
            
            for enabledMove in playerEnabledMoves {
                if let cn = cardNodes.first(where: { cn -> Bool in
                    return cn.name == enabledMove.card.nodeName()
                }), cn != cardNode {
                    let actionScale = SKAction.scale(to: fromGroup.scale, duration: 0.5)
                    cn.run(actionScale)
                }
            }
        }
        
        enabledMoves[localPlayerIdx]?.removeAll()
    }
    
    
    
    func onTransitions(transitions: [CardTransition]) {
        for t in transitions {
            if let fromGroup = sharedGame?.group(by: t.fromGroupId),
                let toGroup = sharedGame?.group(by: t.toGroupId) {
                move(card: t.card,
                     fromGroup: fromGroup,
                     toGroup: toGroup,
                     toTop: t.toTop,
                     waitDuration: t.waitDuration,
                     duration: t.duration)
            }
        }
    }
    
    func testPreview()
    {
    }
}
