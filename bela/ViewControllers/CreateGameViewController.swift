//
//  CreateGameViewController.swift
//  bela
//
//  Created by Kresimir Prcela on 08/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import UIKit

enum GameType
{
    case Pass
    case Enough
}

class CreateGameViewController: UIViewController {
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var turnDurationBtn: UIButton!
    @IBOutlet weak var gameTypeBtn: UIButton!
    @IBOutlet weak var upToBtn: UIButton!
    @IBOutlet weak var betBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    
    
    var durations = [10,20,30,40,50,60]
    var gameTypes:[GameType] = [.Pass,.Enough]
    var upToPoints = [501,1001]
    
    var duration = 30
    var gameType = GameType.Pass
    var upTo = 1001

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func toggleDuration(_ sender: Any) {
        if let idx = durations.index(of: duration) {
            let idxNext = idx.advanced(by: 1)%durations.count
            duration = durations[idxNext]
            turnDurationBtn.setTitle(String(format: lstr("Turn duration"), duration), for: .normal)
        }
    }
    
}
