//
//  GameViewController.swift
//  bela
//
//  Created by Kresimir Prcela on 10/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    @IBOutlet weak var overlayView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overlayView.isHidden = true
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    @IBAction func onMenu(_ sender: Any) {
        overlayView.isHidden = false
    }
    
    @IBAction func onResume(_ sender: Any) {
        overlayView.isHidden = true
    }
    
    @IBAction func onLeave(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
