//
//  Helper.swift
//  bela
//
//  Created by Kresimir Prcela on 06/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation



func lstr(_ key: String) -> String
{
    return NSLocalizedString(key, comment: "")
}

func isAppAlreadyLaunchedOnce() -> Bool
{
    let defaults = UserDefaults.standard
    let keyLaunchedOnce = "isAppAlreadyLaunchedOnce"
    if let _ = defaults.string(forKey: keyLaunchedOnce){
        print("App already launched")
        return true
    }else{
        defaults.set(true, forKey: keyLaunchedOnce)
        print("App launched first time")
        return false
    }
}
