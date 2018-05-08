//
//  RoomViewController.swift
//  bela
//
//  Created by Kresimir Prcela on 06/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import UIKit

enum RoomSection
{
    case Create
    case FreeTables
    case FreePlayers
    case PlayingTables
}

class RoomViewController: UIViewController {
    
    let sections:[RoomSection] = [.Create,.FreeTables,.FreePlayers,.PlayingTables]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension RoomViewController: UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell(frame: .zero)
    }
    
    
}
