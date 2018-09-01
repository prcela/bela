//
//  GameScene.swift
//  karte
//
//  Created by Kresimir Prcela on 31/08/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import UIKit
import SceneKit

class GameScene: SCNScene {
    
    var enabledMoves = [Int:[CardEnabledMove]]()
    var localPlayerIdx = 0
    var playersLbls = [SCNNode]()
    var cardNodes = [SCNNode]()
    
    func didMoveToView() {
        playersLbls.removeAll()
        for idx in 0...3 {
            let lblNode = rootNode.childNode(withName: "P\(idx)", recursively: false)!
            let hNode = rootNode.childNode(withName: "H\(idx)", recursively: false)!
            let cNode = rootNode.childNode(withName: "C\(idx)", recursively: false)!
            hNode.childNodes.forEach({ (node) in
                node.removeFromParentNode()
            })
            let absIdx = (idx+localPlayerIdx)%4
            hNode.name = "Hand\(absIdx)"
            lblNode.name = "Player\(absIdx)"
            cNode.name = "Center\(absIdx)"
            (lblNode.geometry as? SCNText)?.string = "Player \(absIdx)"
            playersLbls.append(lblNode)
        }
        playersLbls.sort { return $0.name! < $1.name! }
        refreshPlayersAliases()
    }
    
    func onGame(cardGame: CardGame)
    {
        playersLbls.forEach { (node) in
            node.childNodes.forEach({ (node) in
                node.removeFromParentNode()
            })
        }
        cardNodes.removeAll()
        for group in cardGame.groups()
        {
            let groupNode = rootNode.childNode(withName: group.id, recursively: false)!
            groupNode.childNodes.forEach { (node) in
                node.removeFromParentNode()
            }
            group.setNodePlacement(node: groupNode)
            
            if group.id == "Hand\(localPlayerIdx)" {
                (group as! LinearGroup).delta = 35
            }
            
            let visible = group.visibility == .Visible || (group.visibility == .VisibleToLocalOnly && group.id.hasSuffix("\(localPlayerIdx)"))
            
            for card in group.cards
            {
                let cardNode = SCNNode.create(card: card)
                cardNode.position = group.position(for: card)
                cardNode.eulerAngles = group.eulerAngles(for: card)
                groupNode.addChildNode(cardNode)
                cardNodes.append(cardNode)
            }
        }
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
    
    @discardableResult
    fileprivate func move(card: Card, fromGroup: CardGroup, toGroup: CardGroup, toTop: Bool, waitDuration:Double, duration: Double) -> Bool {
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
            toGroup.pos.z = Float(sum)*0.1
        }
        
        let fromGroupNode = rootNode.childNode(withName: fromGroup.id, recursively: false)!
        let toGroupNode = rootNode.childNode(withName: toGroup.id, recursively: false)!
        let cardNode = fromGroupNode.childNode(withName: card.nodeName(), recursively: false)!
        let transformTo = cardNode.convertTransform(cardNode.transform, to: toGroupNode)
        cardNode.transform = transformTo
        cardNode.removeFromParentNode()
        toGroupNode.addChildNode(cardNode)
        
        let duration = 0.5
        
        for card in toGroup.cards {
            let actionPos = SCNAction.move(to: toGroup.position(for: card), duration: duration)
            let eulerAngles = toGroup.eulerAngles(for: card)
            let actionRot = SCNAction.rotateTo(x: CGFloat(eulerAngles.x), y: CGFloat(eulerAngles.y), z: CGFloat(eulerAngles.z), duration: duration, usesShortestUnitArc: true)
            let cardNode = toGroupNode.childNode(withName: card.nodeName(), recursively: false)
            
            let actionWait = SCNAction.wait(duration: waitDuration)
            let actionGroup = SCNAction.group([actionPos,actionRot])
            let actionSequence = SCNAction.sequence([actionWait,actionGroup])
            
            cardNode?.runAction(actionSequence)
        }
        return true
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
                (playersLbls[idx].geometry as! SCNText).string = alias
            }
        }
    }
}
