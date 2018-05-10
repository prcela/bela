//
//  MatchCell.swift
//  bela
//
//  Created by Kresimir Prcela on 09/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import UIKit

class MatchCell: UITableViewCell {

    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var lbl4: UILabel!
    
    @IBOutlet weak var name1Lbl: UILabel?
    @IBOutlet weak var name2Lbl: UILabel?
    @IBOutlet weak var name3Lbl: UILabel?
    @IBOutlet weak var name4Lbl: UILabel?
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for lbl in [lbl1,lbl2,lbl3,lbl4] {
            lbl?.layer.borderWidth = 1
            lbl?.layer.cornerRadius = 3
        }
    }

    
    func update(with tableInfo: TableInfo)
    {
        for (idx,nameLbl) in [name1Lbl,name2Lbl,name3Lbl,name4Lbl].enumerated()
        {
            if tableInfo.playersId.count > idx {
                let pId = tableInfo.playersId[idx]
                let player = Room.shared.playersInfo[pId]
                nameLbl?.text = player?.alias
            } else {
                nameLbl?.text = "?"
            }
        }
    }
    
}
