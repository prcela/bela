//
//  GameViewController.swift
//  bela
//
//  Created by Kresimir Prcela on 10/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import UIKit
import SpriteKit
import SwiftyJSON

class GameViewController: UIViewController {

    @IBOutlet weak var overlayView: UIView!
    var scene: GameScene?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(onTransitions(notification:)), name: WsAPI.onTransitions, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overlayView.isHidden = true
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            scene = SKScene(fileNamed: "GameScene") as? GameScene
            
            // Set the scale mode to scale to fit the window
            scene?.scaleMode = .aspectFill
            
            if let tableId = PlayerStat.shared.tableId,
                let tableInfo = Room.shared.tablesInfo[tableId],
                let localPlayerIdx = tableInfo.playersId.index(of: PlayerStat.shared.id)
            {
                scene?.localPlayerIdx = localPlayerIdx
            }
            
            
            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    @objc func onTransitions(notification: Notification) {
        let json = notification.object as! JSON
        let transitions = json.arrayValue.map { (json) -> CardTransition in
            return CardTransition(json: json)
        }
        scene?.onTransitions(transitions: transitions)
    }
    
    @IBAction func onMenu(_ sender: Any) {
        overlayView.isHidden = false
        scene?.isUserInteractionEnabled = false
    }
    
    @IBAction func onResume(_ sender: Any) {
        overlayView.isHidden = true
        scene?.isUserInteractionEnabled = true
        
    }
    
    @IBAction func onLeave(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
