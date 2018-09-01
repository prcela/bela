//
//  CardNode.swift
//  karte
//
//  Created by Kresimir Prcela on 12/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation
import SceneKit

var templateCardNode: SCNNode!

extension SCNNode {
    
    class func create(card:Card) -> SCNNode {
        let cardNodeClone = templateCardNode.clone()
        let frontNode = cardNodeClone.childNode(withName: "front", recursively: false)!
        frontNode.geometry?.material(named: "front")?.diffuse.contents = UIImage(named: card.imageName())
        cardNodeClone.name = card.nodeName()
        return cardNodeClone
    }
    
}
