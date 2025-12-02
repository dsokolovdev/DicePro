//
//  DaceModel.swift
//  DicePro
//
//  Created by Dmitri  on 30.11.25.
//
import UIKit

struct DiceModel  {
    private let diceNameBlackYellow: [String] = ["DiceBlackYellow1", "DiceBlackYellow2", "DiceBlackYellow3", "DiceBlackYellow4", "DiceBlackYellow5", "DiceBlackYellow6"]
    private let diceNameBlueGrey: [String] = ["DiceBlueGrey1", "DiceBlueGrey2", "DiceBlueGrey3", "DiceBlueGrey4", "DiceBlueGrey5", "DiceBlueGrey6"]
    
    var data: GameData = GameData(players: [
        Player(name: Players.player1.name, totalScore: 0, currentScore: 0, attempts: 0, rank: 0, isActive: false),
        Player(name: Players.player2.name, totalScore: 0, currentScore: 0, attempts: 0, rank: 0, isActive: false)
    ])
    
    func roll() -> Int {
        Int.random(in: 0...5)
    }
    
    func setBlackDice(scores: Int) -> String {
        diceNameBlueGrey[scores]
    }
    
    func setBlueDice(scores: Int) -> String {
        diceNameBlackYellow[scores]
    }
}


