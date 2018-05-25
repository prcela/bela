//
//  GraphsViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 04/04/2018.
//  Copyright © 2018 minus5 d.o.o. All rights reserved.
//

import UIKit
import SwiftyJSON

class GraphsViewController: UIViewController {
    
    @IBOutlet weak var graphsView: GraphsView?
    
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
        
        // Do any additional setup after loading the view.
        graphsView?.items = items
    }
    
    override func viewDidLayoutSubviews() {
        graphsView?.updateFrames()
    }
    
    @objc func onStatItems(_ notification: Notification) {
        let json = notification.object as! JSON
        guard playerId == json["player_id"].stringValue else {return}
        items = json["stat_items"].arrayValue.map({ json -> StatItem in
            return StatItem(json: json)
        })
        graphsView?.items = items
    }
    
}
