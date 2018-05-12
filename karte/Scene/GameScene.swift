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
    
    
    override func didMove(to view: SKView) {
        
        let cards: [Card] = [
            Card(boja: .žir, broj: .vii),
            Card(boja: .žir, broj: .dama),
            Card(boja: .srce, broj: .kec),
            Card(boja: .list, broj: .ix),
            Card(boja: .bundeva, broj: .viii),
            Card(boja: .bundeva, broj: .kec),
            Card(boja: .list, broj: .vii)
        ]
        
        for (idx,card) in cards.enumerated() {
            let cardW = size.width * 0.2
            let tex = SKTexture(imageNamed: card.imageName())
            let cardRatio = tex.size().width/tex.size().height
            let cardNode = SKShapeNode(rectOf: CGSize(width: cardW, height: cardW/cardRatio), cornerRadius: cardW*0.08)
            cardNode.fillColor = .white
            cardNode.fillTexture = tex
            cardNode.strokeColor = .black
            cardNode.zPosition = 0.01*CGFloat(idx)
            cardNode.position = CGPoint(x: -150+CGFloat(idx)*40, y: -40+CGFloat(idx)*10)
            addChild(cardNode)
        }
        
        
    }
}
