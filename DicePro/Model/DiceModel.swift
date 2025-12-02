//
//  DaceModel.swift
//  DicePro
//
//  Created by Dmitri  on 30.11.25.
//
import UIKit

struct DiceModel  {
    enum Dices {
        case blackYellow, blackRed, BlueGrey, WhiteBlue
        
        var diceArray: [String] {
            switch self {
            case .BlueGrey: return  ["DiceBlueGrey1", "DiceBlueGrey2", "DiceBlueGrey3", "DiceBlueGrey4", "DiceBlueGrey5", "DiceBlueGrey6"]
            case .WhiteBlue: return ["DiceWhiteBlue1", "DiceWhiteBlue2", "DiceWhiteBlue3", "DiceWhiteBlue4", "DiceWhiteBlue5", "DiceWhiteBlue6"]
            case .blackRed: return ["DiceBlackRed1", "DiceBlackRed2", "DiceBlackRed3", "DiceBlackRed4", "DiceBlackRed5", "DiceBlackRed6"]
            case .blackYellow: return ["DiceBlackYellow1", "DiceBlackYellow2", "DiceBlackYellow3", "DiceBlackYellow4", "DiceBlackYellow5", "DiceBlackYellow6"]
            }
        }
    }
    
    var data: GameData = GameData(players: [
        Player(name: Players.player1.name, totalScore: 0, currentScore: 0, attempts: 0, rank: 0, isActive: false),
        Player(name: Players.player2.name, totalScore: 0, currentScore: 0, attempts: 0, rank: 0, isActive: false)
    ]) {
        didSet { data.updateRanks() }
    }
    
    func roll() -> Int {
        Int.random(in: 0...5)
    }
    
    func setDice(score: Int, color: Dices) -> String {
        let dice = color.diceArray
        
        return dice[score]
    }
}


