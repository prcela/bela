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
    @IBOutlet weak var tableView: UITableView!
    
    
    var durations = [10,20,30,40,50,60]
    var gameTypes:[GameType] = [.Pass,.Enough]
    var upToPoints = [501,701,1001]
    
    var duration = 30
    var gameType = GameType(rawValue: UserDefaults.standard.integer(forKey: Prefs.lastPlayedGameType))!
    var upTo = 1001
    var locked = false
    var bet = UserDefaults.standard.integer(forKey: Prefs.lastBet)
    
    let sections:[RoomSection] = [.FreeTables,.FreePlayers]
    var playersIgnoredInvitation = Set<String>()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(updateTable), name: Room.onInfo, object: nil)
        nc.addObserver(self, selector: #selector(updateTable), name: Room.onJoinedTable, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "MatchCell", bundle: nil), forCellReuseIdentifier: "MatchCellId")
        
        updateTurnDurationBtn()
        updateGameTypeBtn()
        updateUpToBtn()
        updateBetBtn()
        updateLockBtn()
        
        waitingLbl.isHidden = true
        tableView.isHidden = true
    }
    
    @objc func updateTable() {
        tableView.reloadData()
    }

    @IBAction func back(_ sender: Any) {
        if let tableId = PlayerStat.shared.tableId
        {
            let json = JSON(["table_id":tableId])
            WsAPI.shared.send(.LeaveTable, json: json)
            PlayerStat.shared.tableId = nil
        }
        
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
            
            waitingLbl.isHidden = false
            tableView.isHidden = false
            
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
    
    func freePlayers() -> [PlayerInfo]
    {
        let playerId = PlayerStat.shared.id
        let players = Room.shared.freePlayers().filter({ (player) -> Bool in
            return player.id != playerId && !playersIgnoredInvitation.contains(player.id)
        })
        return players
    }
    
}

extension CreateGameViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections[indexPath.section] {
        case .FreeTables:
            return 118
        default:
            return tableView.rowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections[section] {
        case .FreeTables:
            return lstr("Game")
        default:
            return lstr("Invite someone")
        }
    }
}

extension CreateGameViewController: UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .FreeTables:
            return (PlayerStat.shared.tableId != nil) ? 1:0
        case .FreePlayers:
            return freePlayers().count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .FreeTables:
            if let tableId = PlayerStat.shared.tableId,
                let tableInfo = Room.shared.tablesInfo[tableId] {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCellId", for: indexPath) as! MatchCell
                cell.update(with: tableInfo)
                return cell
            }
        default:
            break
        }
        return UITableViewCell(frame: .zero)
    }
}
