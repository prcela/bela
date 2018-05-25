//
//  StatTableViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 03/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit
import SwiftyJSON

class StatTableViewController: UIViewController {
    
    @IBOutlet weak var statsTableView: StatsTableView?
    
    var items: [StatItem]?
    var playerId: String? {
        didSet {
            WsAPI.shared.statItems(playerId: playerId!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(onStatItems(_:)), name: WsAPI.onStatItems, object: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statsTableView?.items = items
    }
    
    override func viewDidLayoutSubviews() {
        statsTableView?.updateFrames()
    }
    
    @objc func onStatItems(_ notification: Notification) {
        let json = notification.object as! JSON
        guard playerId == json["player_id"].stringValue else {return}
        items = json["stat_items"].arrayValue.map({ json -> StatItem in
            return StatItem(json: json)
        })
        statsTableView?.items = items
    }
}

