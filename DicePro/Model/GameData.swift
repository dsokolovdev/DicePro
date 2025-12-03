//
//  DiceModel.swift
//  DicePro
//
//  Created by Dmitri  on 30.11.25.
//
import Foundation

struct GameData: Codable {
    var players: [Player]
    
    mutating func updateRanks() {
        let ranked = players.enumerated().sorted { $0.element > $1.element }
        for (index, player) in ranked.enumerated() {
            players[player.offset].rank = index + 1
        }
    }
//    mutating func updateRanks() {
//        let sorted = players.sorted(by: >)
//        for (rankIndex, player) in sorted.enumerated() {
//            if let realIndex = players.firstIndex(of: player) {
//                players[realIndex].rank = rankIndex + 1
//            }
//        }
//    }
    
}


struct Player: Codable, Equatable, Comparable {
    var name: String
    var totalScore: Int
    var currentScore: Int
    var attempts: Int
    var rank: Int
    var isActive: Bool
    
    init(name: String) {
        self.name = name
        self.totalScore = 0
        self.currentScore = 0
        self.attempts = 0
        self.rank = 0
        self.isActive = false
    }
    
    static func < (lhs: Player, rhs: Player) -> Bool {
        if lhs.totalScore != rhs.totalScore {
            return lhs.totalScore < rhs.totalScore
        }
        return lhs.attempts > rhs.attempts
    }
}
