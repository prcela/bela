//
//  GameViewController.swift
//  bela
//
//  Created by Kresimir Prcela on 10/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import UIKit
import SpriteKit
import SceneKit
import SwiftyJSON

class GameViewController: UIViewController {
    
    static weak var shared: GameViewController?
    
    let stepQueue = OperationQueue()

    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var menuBtn: UIButton!
    
    var scene: GameScene?
    
    @IBOutlet weak var scnView: SCNView!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        GameViewController.shared = self
        stepQueue.maxConcurrentOperationCount = 1
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(onGame), name: WsAPI.onGame, object: nil)
        nc.addObserver(self, selector: #selector(onStep(notification:)), name: WsAPI.onStep, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overlayView.isHidden = true
        menuBtn.setImage(menuBtn.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        if let view = self.view as? SKView {
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
        
        scnView.showsStatistics = true
        
        if let cardScene = SCNScene(named: "Test.scnassets/card.scn"),
            let cardNodeClone = cardScene.rootNode.childNode(withName: "card", recursively: true)?.clone()
        {
            cardNodeClone.position = SCNVector3(x: -0.015, y: 0.116, z: 0.136)
            let frontNode = cardNodeClone.childNode(withName: "front", recursively: false)!
            frontNode.geometry?.material(named: "front")?.diffuse.contents = UIImage(named: "Test.scnassets/bundeva_decko.jpg")
            scnView.scene?.rootNode.addChildNode(cardNodeClone)
        }
        
    }
    
    @objc
    func onGame(notification: Notification) {
        let json = notification.object as! JSON
        sharedGame = Bela(json: json)
        scene?.onGame(cardGame: sharedGame!)
    }
    
    @objc func onStep(notification: Notification) {
        let json = notification.object as! JSON
        let step = CardGameStep(json: json["step"])
        
        let op = BlockOperation {[weak self] in
            
            var totalDuration: TimeInterval = 0
            for t in step.transitions {
                totalDuration = max(totalDuration, t.waitDuration + t.duration)
            }
            
            DispatchQueue.main.async {
                sharedGame?.state = GameState(rawValue: json["state"].intValue)!
                
                self?.scene?.enabledMoves.removeAll()
                self?.scene?.onTransitions(transitions: step.transitions)
            }
            
            
            
            Thread.sleep(forTimeInterval: totalDuration)
            print("Finished transitions for \(totalDuration)s")
            
            DispatchQueue.main.async {
                self?.scene?.enabledMoves = step.enabledMoves
                if let event = step.event,
                    let scene = self?.scene {
                    sharedGame?.onEvent(event: event, scene: scene)
                }
            }
        }
        
        stepQueue.addOperation(op)
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
