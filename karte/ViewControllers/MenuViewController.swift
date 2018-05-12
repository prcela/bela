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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        onlinePlayersCtLbl?.text = String(format: lstr("Online players count"), Room.shared.playersInfo.count)
    }
    
    @objc func onRoomInfo()  {
        onlinePlayersCtLbl?.text = String(format: lstr("Online players count"), Room.shared.playersInfo.count)
    }

    
}
