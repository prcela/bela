//
//  GameScene.swift
//  karte
//
//  Created by Kresimir Prcela on 31/08/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import UIKit
import SceneKit

class GameScene: SCNScene {
    
    var enabledMoves = [Int:[CardEnabledMove]]()
    var localPlayerIdx = 0
    
    func didMoveToView() {
        ...
    }
    
    func onGame(cardGame: CardGame)
    {
    }
    
    func onTransitions(transitions: [CardTransition])
    {
    }
    
    func refreshPlayersAliases()
    {
    }
}
