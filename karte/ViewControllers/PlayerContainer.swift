//
//  PlayerContainer.swift
//  Yamb
//
//  Created by Kresimir Prcela on 02/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class PlayerContainer: ContainerViewController {
    
    var playerId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let profileViewController = storyboard!.instantiateViewController(withIdentifier: "ProfileViewController")
        let statTableViewController = storyboard!.instantiateViewController(withIdentifier: "StatTableViewController") as! StatTableViewController
        let graphsViewController = storyboard!.instantiateViewController(withIdentifier: "GraphsViewController") as! GraphsViewController
        
        statTableViewController.playerId = playerId
        graphsViewController.playerId = playerId
        
        items = [
            ContainerItem(vc:profileViewController, name: "Profile"),
            ContainerItem(vc:statTableViewController, name: "Stat"),
            ContainerItem(vc: graphsViewController, name: "Graphs")
        ]
        let _ = selectByIndex(0)
    }
}

