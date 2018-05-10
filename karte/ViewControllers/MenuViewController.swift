//
//  MenuViewController.swift
//  bela
//
//  Created by Kresimir Prcela on 06/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var onlinePlayersCtLbl: UILabel?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onRoomInfo), name: Room.onInfo, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        onlinePlayersCtLbl?.text = String(format: lstr("Online players count"), Room.shared.playersInfo.count)
    }
    
    @objc func onRoomInfo()  {
        onlinePlayersCtLbl?.text = String(format: lstr("Online players count"), Room.shared.playersInfo.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
