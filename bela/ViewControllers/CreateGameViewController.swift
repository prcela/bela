//
//  CreateGameViewController.swift
//  bela
//
//  Created by Kresimir Prcela on 08/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import UIKit
import SwiftyJSON
import Firebase

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
    @IBOutlet weak var waitingLbl: UILabel!
    
    
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
        updateTurnDurationBtn()
        updateGameTypeBtn()
        updateUpToBtn()
        updateBetBtn()
        updateLockBtn()
    }

    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func toggleDuration(_ sender: Any) {
        if let idx = durations.index(of: duration) {
            let idxNext = idx.advanced(by: 1)%durations.count
            duration = durations[idxNext]
            updateTurnDurationBtn()
        }
    }
    
    fileprivate func updateTurnDurationBtn() {
        turnDurationBtn.setTitle(String(format: lstr("Turn duration"), duration), for: .normal)
    }
    
    @IBAction func toggleGameType(_ sender: Any) {
        if let idx = gameTypes.index(of: gameType) {
            let idxNext = idx.advanced(by: 1)%gameTypes.count
            gameType = gameTypes[idxNext]
            updateGameTypeBtn()
            UserDefaults.standard.set(gameType.rawValue, forKey: Prefs.lastPlayedGameType)
        }
    }
    
    fileprivate func updateGameTypeBtn() {
        gameTypeBtn.setTitle(String(format: lstr("Game type"), gameType.title()), for: .normal)
    }
    
    @IBAction func toggleUpToPoints(_ sender: Any) {
        if let idx = upToPoints.index(of: upTo) {
            let idxNext = idx.advanced(by: 1)%upToPoints.count
            upTo = upToPoints[idxNext]
            updateUpToBtn()
        }
    }
    
    fileprivate func updateUpToBtn() {
        upToBtn.setTitle(String(format: lstr("Playing up to points"), upTo), for: .normal)
    }
    
    @IBAction func toggleBet(_ sender: Any) {
        if bet + 5 <= PlayerStat.shared.diamonds {
            bet += 5
            UserDefaults.standard.set(bet, forKey: Prefs.lastBet)
            updateBetBtn()
        } else {
            suggestBuyDiamonds()
        }
    }
    
    fileprivate func updateBetBtn() {
        betBtn.setTitle(String(format: lstr("Bet value"), bet), for: .normal)
    }
    
    @IBAction func toggleLock(_ sender: Any) {
        locked = !locked
        updateLockBtn()
    }
    fileprivate func updateLockBtn() {
        lockBtn.setTitle(locked ? "🔒":"🔓", for: .normal)
    }
    
    @IBAction func create(_ sender: Any) {
        if bet <= PlayerStat.shared.diamonds
        {
            turnDurationBtn.isHidden = true
            gameTypeBtn.isHidden = true
            upToBtn.isHidden = true
            betBtn.isHidden = true
            lockBtn.isHidden = true
            createBtn.isHidden = true
            
            let params:[String:Any] = [
                "turn_duration":duration,
                "bet":bet,
                "private":locked,
                "players_id": [PlayerStat.shared.id],
                "game_type":gameType.rawValue,
                "up_to_points":upTo
            ]
            
            let json = JSON(params)
            WsAPI.shared.send(.CreateTable, json: json)
            Analytics.logEvent("create_table", parameters: nil)
        }
        else
        {
            suggestBuyDiamonds()
        }
    }
    
}
