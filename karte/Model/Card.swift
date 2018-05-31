//
//  card.swift
//  karte
//
//  Created by Kresimir Prcela on 12/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Card {
    let boja: Boja
    let broj: Broj
    
    init(boja: Boja, broj: Broj) {
        self.boja = boja
        self.broj = broj
    }
    
    func imageName() -> String {
        let naziv = String("\(boja)_\(broj).jpg")
        return naziv
    }
    
    func nodeName() -> String {
        return "card_\(boja)_\(broj)"
    }
    
    func dictionary() -> [String:Any] {
        return [
            "boja":boja.rawValue,
            "broj":broj.rawValue
        ]
    }
    
    init(json: JSON) {
        boja = Boja(rawValue: json["boja"].stringValue)!
        broj = Broj(rawValue: json["broj"].intValue)!
    }
}

extension Card: Equatable {
    static func == (lhs: Card, rhs: Card) -> Bool {
        return
            lhs.boja == rhs.boja &&
                lhs.broj == rhs.broj
    }
}


enum Boja: String {
    case žir = "žir"
    case bundeva = "bundeva"
    case srce = "srce"
    case list = "list"
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
