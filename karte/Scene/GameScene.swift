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
        
        let cardNames = ["žir_kec.jpg","žir_vii.jpg"]
        
        for (idx,cardName) in cardNames.enumerated() {
            let cardW = size.width * 0.3
            let cardRatio = CGFloat(374)/CGFloat(587)
            let cardNode = SKShapeNode(rectOf: CGSize(width: cardW, height: cardW/cardRatio), cornerRadius: cardW*0.08)
            cardNode.fillColor = .white
            cardNode.fillTexture = SKTexture(imageNamed: cardName)
            cardNode.strokeColor = .black
            cardNode.zPosition = 0.01*CGFloat(idx)
            cardNode.position = CGPoint(x: CGFloat(idx)*40, y: CGFloat(idx)*10)
            addChild(cardNode)
        }
        
        
    }
}
