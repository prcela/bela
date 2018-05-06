//
//  ViewController.swift
//  bela
//
//  Created by Kresimir Prcela on 05/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class MainViewController: UIViewController {

    @IBOutlet weak var playerBtn: UIButton?
    @IBOutlet weak var connectingLbl: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        PlayerStat.loadStat()
        Analytics.setUserID(PlayerStat.shared.id)
        
        WsAPI.shared.connect()
    }

}

