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
            let cardSize = CGSize(width: cardW, height: cardW/cardRatio)
            let cardNode = SKCropNode()
            let shapeNode = SKShapeNode(rectOf: cardSize, cornerRadius: cardW*0.08)
            cardNode.maskNode = shapeNode
            let spriteNode = SKSpriteNode(texture: tex, size: cardSize)
            cardNode.addChild(spriteNode)
            cardNode.name = "card"
            shapeNode.fillColor = .white
            shapeNode.strokeColor = .black
            cardNode.zPosition = 0.01*CGFloat(idx)
            cardNode.position = CGPoint(x: -150+CGFloat(idx)*40, y: -40+CGFloat(idx)*10)
            addChild(cardNode)
        }
        
        
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
            let action = SKAction.move(by: CGVector(dx: 10, dy: 50), duration: 0.2)
            let action1 = SKAction.rotate(byAngle: CGFloat.pi, duration: 0.2)
            card.run(action)
            card.run(action1)
        }
    }
}
