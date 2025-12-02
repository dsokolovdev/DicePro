//
//  DiceModel.swift
//  DicePro
//
//  Created by Dmitri  on 30.11.25.
//
import Foundation

struct GameData {
    var players: [Player]
    
    private func sortPlayers() -> [Player] {
        return players.sorted(by: >)
    }
    
    mutating func updateRanks() {
        let rankedPlayers = sortPlayers()
        for (index, player) in rankedPlayers.enumerated() {
            players[players.firstIndex(of: player)!].rank = index + 1
        }
    }
    
}


struct Player: Equatable, Comparable {
    var name: String
    var totalScore: Int
    var currentScore: Int
    var attempts: Int
    var rank: Int
    var isActive: Bool
    
    static func < (lhs: Player, rhs: Player) -> Bool {
        if lhs.totalScore != rhs.totalScore {
            return lhs.totalScore < rhs.totalScore
        }
        return lhs.attempts > rhs.attempts
    }
}
