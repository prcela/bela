//
//  StatsTableView.swift
//  karte
//
//  Created by Kresimir Prcela on 25/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation
import UIKit

class StatsTableView: UIView
{
    var items: [StatItem]? {
        didSet {
            if items != oldValue {
                refresh()
            }
        }
    }
    
    func refresh() {
        // TODO...
    }
    
    func updateFrames()
    {
        // TODO...
    }
}
