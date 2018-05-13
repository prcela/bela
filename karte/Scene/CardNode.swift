//
//  CardNode.swift
//  karte
//
//  Created by Kresimir Prcela on 12/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation
import SpriteKit

class CardNode: SKCropNode {
    var frontNode: SKSpriteNode?
    var backNode: SKSpriteNode?
    
    init(card:Card, width: CGFloat) {
        
        let tex = SKTexture(imageNamed: card.imageName())
        let texDeck = SKTexture(imageNamed: "deck.jpg")
        let cardRatio = tex.size().width/tex.size().height
        let cardSize = CGSize(width: width, height: width/cardRatio)
        let shapeNode = SKShapeNode(rectOf: cardSize, cornerRadius: width*0.08)
        frontNode = SKSpriteNode(texture: tex, size: cardSize)
        backNode = SKSpriteNode(texture: texDeck, size: cardSize)
        backNode?.isHidden = true
        shapeNode.fillColor = .white
        shapeNode.strokeColor = .black
        super.init()
        maskNode = shapeNode
        name = card.nodeName()
        addChild(frontNode!)
        addChild(backNode!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
