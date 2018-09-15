//
//  CardNode.swift
//  karte
//
//  Created by Kresimir Prcela on 12/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation
import SceneKit



extension SCNNode {
    
    class func create(card:Card, templateCardNode:SCNNode) -> SCNNode {
        let cardNodeClone = templateCardNode.clone()
        let frontNodeTemplate = templateCardNode.childNode(withName: "front", recursively: false)!
        let frontNodeClone = cardNodeClone.childNode(withName: "front", recursively: false)!
        
        frontNodeClone.geometry = frontNodeTemplate.geometry!.copy() as? SCNGeometry
        frontNodeClone.geometry?.materials = frontNodeTemplate.geometry!.materials.map({ (mat) -> SCNMaterial in
            return mat.copy() as! SCNMaterial
        })
        frontNodeClone.geometry?.material(named: "front")?.diffuse.contents = UIImage(named: card.imageName())
        cardNodeClone.name = card.nodeName()
        return cardNodeClone
    }
    
}
