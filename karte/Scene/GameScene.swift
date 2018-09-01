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
            let hNode = rootNode.childNode(withName: "H\(idx)", recursively: false)
            hNode?.childNodes.forEach({ (node) in
                node.removeFromParentNode()
            })
            let absIdx = (idx+localPlayerIdx)%4
            hNode?.name = "Hand\(absIdx)"
            lblNode.name = "Player\(absIdx)"
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
    
    func onTransitions(transitions: [CardTransition])
    {
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
