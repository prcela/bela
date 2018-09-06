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
        
        scene = GameScene(named: "Test.scnassets/game.scn")
        scnView.scene = scene
        scene?.didMoveToView()
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        scnView.gestureRecognizers = [tapGestureRecognizer, panGestureRecognizer]
        
        
        scnView.showsStatistics = true
        
        if let cardScene = SCNScene(named: "Test.scnassets/card.scn"),
            let cardNode = cardScene.rootNode.childNode(withName: "card", recursively: true)
        {
            templateCardNode = cardNode
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
    
    @objc
    func handleGesture(recognizer: UIPanGestureRecognizer)
    {
        let point = recognizer.location(in: scnView)
        let result = scnView.hitTest(point, options: nil)
        scene?.hitNode = result.first?.node
        
        switch recognizer.state {
        case .ended:
            scene?.onTouchUp()
            scene?.hitNode = nil
        default:
            break
        }
    }
    
    @objc
    func handleTap(recognizer: UITapGestureRecognizer)
    {
        let point = recognizer.location(in: scnView)
        let result = scnView.hitTest(point, options: nil)
        scene?.hitNode = result.first?.node
        
        switch recognizer.state {
        case .ended:
            scene?.onTouchUp()
            scene?.hitNode = nil
        default:
            break
        }
    }
    
    
    
    @IBAction func onMenu(_ sender: Any) {
        overlayView.isHidden = false
        scnView?.isUserInteractionEnabled = false
    }
    
    @IBAction func onResume(_ sender: Any) {
        overlayView.isHidden = true
        scnView?.isUserInteractionEnabled = true
        
    }
    
    @IBAction func onLeave(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
