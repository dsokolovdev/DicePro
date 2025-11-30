//
//  DiceModel.swift
//  DicePro
//
//  Created by Dmitri  on 30.11.25.
//
import Foundation

struct GameData {
    var players: [Player]
    
}


struct Player {
    var name: String
    var totalScore: Int
    var currentScore: Int
    var turn: Int
    var rank: Int
}
