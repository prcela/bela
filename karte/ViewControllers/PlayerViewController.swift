//
//  PlayerViewController.swift
//  karte
//
//  Created by Kresimir Prcela on 24/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController
{
    var playerId: String?
    
    @IBOutlet weak var profileBtn: UnderlineButton!
    @IBOutlet weak var statsBtn: UnderlineButton!
    @IBOutlet weak var graphsBtn: UnderlineButton!
    
    weak var playerContainer: PlayerContainer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        showProfile(profileBtn)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embed"
        {
            playerContainer = segue.destination as? PlayerContainer
            playerContainer?.playerId = playerId
        }
    }

    @IBAction func showProfile(_ sender: AnyObject)
    {
        profileBtn.isSelected = true
        statsBtn.isSelected = false
        graphsBtn.isSelected = false
        
        let _ = playerContainer?.selectByName("Profile", completion: nil)
    }
    
    @IBAction func showStats(_ sender: AnyObject)
    {
        profileBtn.isSelected = false
        statsBtn.isSelected = true
        graphsBtn.isSelected = false
        
        let _ = playerContainer?.selectByName("Stat", completion: nil)
    }
    
    @IBAction func showGraphs(_ sender: Any) {
        profileBtn.isSelected = false
        statsBtn.isSelected = false
        graphsBtn.isSelected = true
        
        let _ = playerContainer?.selectByName("Graphs", completion: nil)
    }
    
    
    @IBAction func close(_ sender: AnyObject)
    {
        dismiss(animated: true, completion: nil)
    }

}
