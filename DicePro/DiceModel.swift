//
//  DaceModel.swift
//  DicePro
//
//  Created by Dmitri  on 30.11.25.
//
import UIKit

struct DiceModel  {
    let diceNameBlackYellow: [String] = ["DiceBlackYellow1", "DiceBlackYellow2", "DiceBlackYellow3", "DiceBlackYellow4", "DiceBlackYellow5", "DiceBlackYellow6"]
    let diceNameBlueGrey: [String] = ["DiceBlueGrey1", "DiceBlueGrey2", "DiceBlueGrey3", "DiceBlueGrey4", "DiceBlueGrey5", "DiceBlueGrey6"]
    
    var data: GameData
    
    init() {
        self.data = GameData(players: [])
    }
    
    func roll() -> Int {
        Int.random(in: 0...5)
    }
}


