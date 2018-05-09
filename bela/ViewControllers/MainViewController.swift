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
    
    static var shared: MainViewController?

    @IBOutlet weak var playerBtn: UIButton?
    @IBOutlet weak var connectingLbl: UILabel?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let nc = NotificationCenter.default
        
        nc.addObserver(self, selector: #selector(onWsConnect), name: WsAPI.onConnect, object: nil)
        nc.addObserver(self, selector: #selector(onWsDidConnect), name: WsAPI.onDidConnect, object: nil)
        nc.addObserver(self, selector: #selector(onWsDidDisconnect), name: WsAPI.onDidDisconnect, object: nil)
        nc.addObserver(self, selector: #selector(onPlayerStat), name: WsAPI.onPlayerStatReceived, object: nil)
        
        MainViewController.shared = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        connectingLbl?.isHidden = false
        connectingLbl?.text = lstr("Connecting...")
        
        PlayerStat.loadStat()
        Analytics.setUserID(PlayerStat.shared.id)
        
        WsAPI.shared.connect()
    }
    
    func evaluateRetention()
    {
        let calendar = Calendar.current
        let dateNow = Date()
        let dayNow = (calendar as NSCalendar).ordinality(of: .day, in: .era, for: dateNow)
        
        //        PlayerStat.shared.retentions = [736330] // test
        
        if let lastRetention = PlayerStat.shared.retentions.last
        {
            if dayNow == lastRetention
            {
                // ignore it
                return
            }
            else if dayNow != lastRetention + 1
            {
                // remove all old retentions
                print("reward")
                PlayerStat.shared.retentions.removeAll()
            }
        }
        
        PlayerStat.shared.retentions.append(dayNow)
        // TODO: self.performSegue(withIdentifier: "retention", sender: self)
        PlayerStat.shared.updateToServer()
    }

    
    @objc func onWsConnect()
    {
        connectingLbl?.isHidden = false
    }
    
    @objc func onWsDidConnect()
    {
        connectingLbl?.isHidden = true
        WsAPI.shared.playerStat()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
            WsAPI.shared.sendUnsentMessages()
        }
    }
    
    @objc func onWsDidDisconnect()
    {
        connectingLbl?.isHidden = false
    }
    
    @objc func onPlayerStat()
    {
        if isAppAlreadyLaunchedOnce() {
            evaluateRetention()
        }
        refreshPlayerInfo()
    }
    
    @objc func refreshPlayerInfo()
    {
        let p = PlayerStat.shared
        let name = p.alias
        let diamonds = p.diamonds
        
        
        let playerTitle = "\(name)  💎 \(diamonds)"
        playerBtn?.setTitle(playerTitle, for: .normal)
    }

}

