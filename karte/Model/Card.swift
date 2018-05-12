//
//  card.swift
//  karte
//
//  Created by Kresimir Prcela on 12/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation

struct Card {
    let boja: Boja
    let broj: Broj
    
    func imageName() -> String {
        let naziv = String("\(boja)_\(broj).jpg")
        return naziv
    }
    
    func nodeName() -> String {
        return "\(boja)_\(broj)"
    }
}

enum Boja {
    case žir
    case bundeva
    case srce
    case list
}

enum Broj: Int {
    case vii = 7
    case viii
    case ix
    case x
    case dečko
    case dama
    case kralj
    case kec
}
