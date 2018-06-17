//
//  CardGame.swift
//  karte
//
//  Created by Kresimir Prcela on 27/05/2018.
//  Copyright © 2018 prcela. All rights reserved.
//

import Foundation

var sharedGame: CardGame!

protocol CardGame: class
{
    var state: GameState {get set}
    func groups() -> [CardGroup]
    func group(by id: String) -> CardGroup?
    func idxOfPlayerOnTurn() -> Int
}
