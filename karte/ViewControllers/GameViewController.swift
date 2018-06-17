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
    
    static weak var shared: GameViewController?

    @IBOutlet weak var overlayView: UIView!
    var scene: GameScene?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        GameViewController.shared = self
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(onGame), name: WsAPI.onGame, object: nil)
        nc.addObserver(self, selector: #selector(onStep(notification:)), name: WsAPI.onStep, object: nil)
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
    
    @objc
    func onGame(notification: Notification) {
        let json = notification.object as! JSON
        sharedGame = Bela(json: json)
        scene?.onGame(cardGame: sharedGame!)
    }
    
    @objc func onStep(notification: Notification) {
        let json = notification.object as! JSON
        sharedGame.state = GameState(rawValue: json["state"].intValue)!
        let transitions = json["transitions"].arrayValue.map { (json) -> CardTransition in
            return CardTransition(json: json)
        }
        scene?.enabledMoves.removeAll()
        scene?.onTransitions(transitions: transitions) {
            print("Finished transitions")
            for (key,json) in json["enabled_moves"].dictionaryValue {
                self.scene?.enabledMoves[Int(key)!] = json.arrayValue.map({ (json) -> CardEnabledMove in
                    return CardEnabledMove(json: json)
                })
            }
        }
        
        
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
