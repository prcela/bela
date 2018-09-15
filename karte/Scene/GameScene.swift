//
//  GameScene.swift
//  karte
//
//  Created by Kresimir Prcela on 31/08/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import UIKit
import SceneKit
import SwiftyJSON

class GameScene: SCNScene {
    
    var templateCardNode: SCNNode!
    var adutNode: SCNNode!
    
    var enabledMoves = [Int:[CardEnabledMove]]() {
        didSet {
            let localMoves = enabledMoves[localPlayerIdx] ?? []
            for move in localMoves {
                if let node = rootNode.childNode(withName: move.card.nodeName(), recursively: true) {
                    let scale = SCNAction.scale(to: 1.2, duration: 0.2)
                    node.runAction(scale)
                }
            }
            
            for (idx,lblNode) in playersLbls.enumerated() {
                if let _ = enabledMoves[idx] {
                    lblNode.geometry?.materials.first?.diffuse.contents = UIColor.yellow
                } else {
                    lblNode.geometry?.materials.first?.diffuse.contents = UIColor.white
                }
            }
            
            if let myHandCards = sharedGame?.group(by: "Hand\(localPlayerIdx)")?.cards
            {
                for card in myHandCards
                {
                    let node = rootNode.childNode(withName: card.nodeName(), recursively: true)
                    let frontNode = node?.childNode(withName: "front", recursively: false)
                    if localMoves.contains(where: { (cem) -> Bool in
                        return cem.card == card
                    }) {
                        frontNode?.geometry?.material(named: "front")?.multiply.contents = UIColor.white
                    } else {
                        frontNode?.geometry?.material(named: "front")?.multiply.contents = UIColor(white: 0.9, alpha: 1)
                    }
                }
            }
        }
    }
    var localPlayerIdx = 0 {
        didSet {
            print("Local player index: \(localPlayerIdx)")
        }
    }
    
    var hitNode: SCNNode? {
        didSet {
            if hitNode != oldValue {
                hitNode?.geometry?.firstMaterial?.emission.contents = UIColor.red
                oldValue?.geometry?.firstMaterial?.emission.contents = UIColor.clear
            }
        }
    }
    
    var playersLbls = [SCNNode]()
    var cardNodes = [SCNNode]()
    
    func didMoveToView() {
        playersLbls.removeAll()
        
        if let tableId = PlayerStat.shared.tableId,
            let tableInfo = Room.shared.tablesInfo[tableId],
            let localPlayerIdx = tableInfo.playersId.index(of: PlayerStat.shared.id)
        {
            self.localPlayerIdx = localPlayerIdx
        }
        
        for idx in 0...3 {
            let lblNode = rootNode.childNode(withName: "P\(idx)", recursively: false)!
            let hNode = rootNode.childNode(withName: "H\(idx)", recursively: false)!
            let cNode = rootNode.childNode(withName: "C\(idx)", recursively: false)!
            let aNode = rootNode.childNode(withName: "A\(idx)", recursively: false)!
            hNode.childNodes.forEach({ (node) in
                node.removeFromParentNode()
            })
            let absIdx = (idx+localPlayerIdx)%4
            hNode.name = "Hand\(absIdx)"
            lblNode.name = "Player\(absIdx)"
            cNode.name = "Center\(absIdx)"
            aNode.name = "Adut\(absIdx)"
            (lblNode.geometry as? SCNText)?.string = "Player \(absIdx)"
            playersLbls.append(lblNode)
        }
        playersLbls.sort { return $0.name! < $1.name! }
        refreshPlayersAliases()
        
        for group in sharedGame?.groups() ?? []
        {
            let groupNode = rootNode.childNode(withName: group.id, recursively: false)!
            groupNode.childNodes.forEach { (node) in
                node.removeFromParentNode()
            }
            group.setNodePlacement(node: groupNode)
        }
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
            
            let visible = group.visibility == .Visible || (group.visibility == .VisibleToLocalOnly && group.id.hasSuffix("\(localPlayerIdx)"))
            
            for card in group.cards
            {
                let cardNode = SCNNode.create(card: card, templateCardNode: templateCardNode)
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
    
    fileprivate func reorderCardsInGroup(_ group: CardGroup, _ duration: Double, _ groupNode: SCNNode, _ waitDuration: Double) {
        for card in group.cards {
            let actionPos = SCNAction.move(to: group.position(for: card), duration: duration)
            let eulerAngles = group.eulerAngles(for: card)
            let actionRot = SCNAction.rotateTo(x: CGFloat(eulerAngles.x), y: CGFloat(eulerAngles.y), z: CGFloat(eulerAngles.z), duration: duration, usesShortestUnitArc: true)
            let actionScale = SCNAction.scale(to: 1, duration: duration)
            let cardNode = groupNode.childNode(withName: card.nodeName(), recursively: false)
            
            let actionWait = SCNAction.wait(duration: waitDuration)
            let actionGroup = SCNAction.group([actionPos,actionRot,actionScale])
            let actionSequence = SCNAction.sequence([actionWait,actionGroup])
            
            cardNode?.runAction(actionSequence)
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
        
        reorderCardsInGroup(toGroup, duration, toGroupNode, waitDuration)
        
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
                let bbox = playersLbls[idx].boundingBox
                playersLbls[idx].pivot = SCNMatrix4MakeTranslation((bbox.max.x-bbox.min.x)/2, 0, 0)
            }
        }
    }
    
    func onTouchUp()
    {
        guard let playerEnabledMoves = enabledMoves[localPlayerIdx],
            let hitCardNode = hitNode?.parent,
            let enabledMove = playerEnabledMoves.first(where: { (enabledMove) -> Bool in
                return enabledMove.card.nodeName() == hitCardNode.name
            })
            else { return }
        
        
        if let fromGroup = sharedGame?.group(by: enabledMove.fromGroupId)
        {
            for enabledMove in playerEnabledMoves {
                if let cn = cardNodes.first(where: { cn -> Bool in
                    return cn.name == enabledMove.card.nodeName()
                })
                {
                    let actionScale = SCNAction.scale(to: 1, duration: 0.5)
                    cn.runAction(actionScale)
                }
            }
            
            if let toGroupId = enabledMove.toGroupId,
                let toGroup = sharedGame?.group(by: toGroupId)
            {
                move(card: enabledMove.card, fromGroup: fromGroup, toGroup: toGroup, toTop: false, waitDuration: 0, duration: 0.5)
            }
            let fromGroupNode = rootNode.childNode(withName: fromGroup.id, recursively: false)!
            reorderCardsInGroup(fromGroup, 0.5, fromGroupNode, 0)
        }
        
        WsAPI.shared.send(.Turn, json: JSON(["turn":"tap_card", "enabled_move":enabledMove.dictionary()]))
        
        enabledMoves[localPlayerIdx]?.removeAll()
    }
}
