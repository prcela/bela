//
//  MenuViewController.swift
//  bela
//
//  Created by Kresimir Prcela on 06/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import UIKit
import SwiftyJSON

class MenuViewController: UIViewController {

    @IBOutlet weak var onlinePlayersCtLbl: UILabel?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(onRoomInfo), name: Room.onInfo, object: nil)
        nc.addObserver(self, selector: #selector(joinedTable), name: WsAPI.onPlayerJoinedToTable, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        onlinePlayersCtLbl?.text = String(format: lstr("Online players count"), Room.shared.playersInfo.count)
    }
    
    @objc func onRoomInfo()  {
        onlinePlayersCtLbl?.text = String(format: lstr("Online players count"), Room.shared.playersInfo.count)
    }

    @objc func joinedTable(notification: Notification) {
        let json = notification.object as! JSON
        let joinedPlayerId = json["joined_player_id"].stringValue
        guard joinedPlayerId == PlayerStat.shared.id else {return}
        
        // ooo thats me
        let gameVC = UIStoryboard(name: "Game", bundle: nil).instantiateInitialViewController()!
        navigationController?.pushViewController(gameVC, animated: true)
    }
}
