//
//  RoomViewController.swift
//  bela
//
//  Created by Kresimir Prcela on 06/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import UIKit

enum RoomSection
{
    case Create
    case FreeTables
    case FreePlayers
    case PlayingTables
}

class RoomViewController: UIViewController {
    
    let sections:[RoomSection] = [.Create,.FreeTables,.FreePlayers,.PlayingTables]
    @IBOutlet weak var tableView: UITableView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: Room.onInfo, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView?.register(UINib(nibName: "MatchCell", bundle: nil), forCellReuseIdentifier: "MatchCellId")
        WsAPI.shared.send(.RoomInfo)
    }
    
    func freePlayers() -> [PlayerInfo] {
        return Room.shared.freePlayers().filter({ (pi) -> Bool in
            return pi.id != PlayerStat.shared.id
        })
    }
    
    @objc func reload() {
        tableView?.reloadData()
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension RoomViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections[section] {
        case .FreePlayers:
            return lstr("Free players")
        case .FreeTables:
            return lstr("Free tables")
        case .PlayingTables:
            return lstr("Playing tables")
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch sections[indexPath.section] {
        case .Create:
            performSegue(withIdentifier: "createGame", sender: nil)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections[indexPath.section] {
        case .FreeTables:
            return 118
        default:
            return tableView.rowHeight
        }
    }
}

extension RoomViewController: UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        
        case .Create:
            let isFreePlayer = Room.shared.freePlayers().contains(where: { (playerInfo) -> Bool in
                return playerInfo.id == PlayerStat.shared.id
            })
            return isFreePlayer ? 1:0
            
        case .FreePlayers:
            return freePlayers().count
        case .FreeTables:
            return Room.shared.freeTables().count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .Create:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellId")!
            cell.textLabel?.text = lstr("Create new")
            cell.accessoryType = .disclosureIndicator
            return cell
        case .FreePlayers:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellId")!
            let player = freePlayers()[indexPath.row]
            cell.textLabel?.text = player.alias
            cell.accessoryType = .disclosureIndicator
            return cell
        case .FreeTables:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCellId", for: indexPath) as! MatchCell
            let table = Room.shared.freeTables()[indexPath.row]
            cell.update(with: table)
            return cell
        default:
            break
        }
        return UITableViewCell(frame: .zero)
    }
}
