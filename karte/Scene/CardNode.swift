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
    init(card:Card, width: CGFloat) {
        super.init()
        let tex = SKTexture(imageNamed: card.imageName())
        let cardRatio = tex.size().width/tex.size().height
        let cardSize = CGSize(width: width, height: width/cardRatio)
        let shapeNode = SKShapeNode(rectOf: cardSize, cornerRadius: width*0.08)
        maskNode = shapeNode
        let spriteNode = SKSpriteNode(texture: tex, size: cardSize)
        addChild(spriteNode)
        name = card.nodeName()
        shapeNode.fillColor = .white
        shapeNode.strokeColor = .black
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
