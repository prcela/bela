//
//  CreateGameViewController.swift
//  bela
//
//  Created by Kresimir Prcela on 08/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import UIKit

enum GameType: Int
{
    case Pass = 0
    case Enough
    
    func title() -> String
    {
        switch self {
        case .Pass:
            return lstr("Pass")
        case .Enough:
            return lstr("Enough")
        }
    }
}

class CreateGameViewController: UIViewController {
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var turnDurationBtn: UIButton!
    @IBOutlet weak var gameTypeBtn: UIButton!
    @IBOutlet weak var upToBtn: UIButton!
    @IBOutlet weak var betBtn: UIButton!
    @IBOutlet weak var lockBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    
    
    var durations = [10,20,30,40,50,60]
    var gameTypes:[GameType] = [.Pass,.Enough]
    var upToPoints = [501,1001]
    
    var duration = 30
    var gameType = GameType(rawValue: UserDefaults.standard.integer(forKey: Prefs.lastPlayedGameType))!
    var upTo = 1001
    var locked = false
    var bet = UserDefaults.standard.integer(forKey: Prefs.lastBet)

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
    
    @IBAction func toggleGameType(_ sender: Any) {
        if let idx = gameTypes.index(of: gameType) {
            let idxNext = idx.advanced(by: 1)%gameTypes.count
            gameType = gameTypes[idxNext]
            gameTypeBtn.setTitle(String(format: lstr("Game type"), gameType.title()), for: .normal)
            UserDefaults.standard.set(gameType.rawValue, forKey: Prefs.lastPlayedGameType)
        }
    }
    
    @IBAction func toggleUpToPoints(_ sender: Any) {
        if let idx = upToPoints.index(of: upTo) {
            let idxNext = idx.advanced(by: 1)%upToPoints.count
            upTo = upToPoints[idxNext]
            upToBtn.setTitle(String(format: lstr("Playing up to points"), upTo), for: .normal)
        }
    }
    
    fileprivate func updateBetBtn() {
        betBtn.setTitle(String(format: lstr("Bet value"), bet), for: .normal)
    }
    
    @IBAction func toggleBet(_ sender: Any) {
        if bet + 5 <= PlayerStat.shared.diamonds {
                bet += 5
                UserDefaults.standard.set(bet, forKey: Prefs.lastBet)
        } else {
            suggestBuyDiamonds()
        }
    }
}
