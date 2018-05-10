//
//  Room.swift
//  bela
//
//  Created by Kresimir Prcela on 08/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation
import SwiftyJSON

class Room {
    static let onInfo = Notification.Name("Room.onInfo")
    static var shared = Room()
    
    var playersInfo = [String:PlayerInfo]()
    var tablesInfo = [String:TableInfo]()
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(onRoomInfo), name: WsAPI.onRoomInfo, object: nil)
    }
    
    @objc func onRoomInfo(notification: Notification)
    {
        let json = notification.object as! JSON
        playersInfo = json["players"].dictionaryValue.mapValues({ (json) -> PlayerInfo in
            let pi = PlayerInfo(json: json)
            if pi.id == PlayerStat.shared.id {
                PlayerStat.shared.alias = pi.alias
                PlayerStat.shared.diamonds = pi.diamonds
                PlayerStat.shared.tableId = pi.tableId
            }
            return pi
        })
        tablesInfo = json["tables"].dictionaryValue.mapValues({ (json) -> TableInfo in
            return TableInfo(json: json)
        })
        NotificationCenter.default.post(name: Room.onInfo, object: nil)
    }
    
    func freePlayers() -> [PlayerInfo] {
        return playersInfo.filter({ (arg) -> Bool in
            let (_, player) = arg
            return player.tableId == nil
        }).map({ (_,pi) -> PlayerInfo in
            return pi
        }).sorted(by: { (pi0, pi1) -> Bool in
            return pi0.alias < pi1.alias
        })
    }
}
