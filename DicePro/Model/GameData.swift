//
//  DiceModel.swift
//  DicePro
//
//  Created by Dmitri on 30.11.25.
//

import Foundation

// MARK: - Game Data Model
/// Stores all player information and provides ranking logic.
struct GameData: Codable {
    
    /// List of players participating in the game.
    var players: [Player]
    
    // MARK: - Ranking Logic
    /**
     Updates player ranks based on their score and attempts.
     
     Sorting rules (defined in Player Comparable):
     - Higher totalScore ranks higher.
     - If scores are equal, fewer attempts ranks higher.
     
     The ranking is recomputed after each score update.
     */
    mutating func updateRanks() {
        let ranked = players.enumerated().sorted { $0.element > $1.element }
        
        for (index, player) in ranked.enumerated() {
            players[player.offset].rank = index + 1
        }
    }
}


// MARK: - Player Model
/// Represents a single player with score, rank, and activity state.
struct Player: Codable, Equatable, Comparable {
    
    // MARK: - Player Properties
    /// Player display name (P1, P2, etc.).
    var name: String
    
    /// Accumulated total score.
    var totalScore: Int
    
    /// Score obtained from the last roll.
    var currentScore: Int
    
    /// Number of rolls made by this player.
    var attempts: Int
    
    /// Player rank (1 = highest).
    var rank: Int
    
    /// Indicates if this player is currently selected in UI.
    var isActive: Bool
    
    
    // MARK: - Initialization
    /// Creates a new player with zeroed stats.
    init(name: String) {
        self.name = name
        self.totalScore = 0
        self.currentScore = 0
        self.attempts = 0
        self.rank = 0
        self.isActive = false
    }
    
    
    // MARK: - Comparable Conformance
    /**
     Compares two players when sorting by rank:
     
     1. The one with **higher totalScore** wins.
     2. If scores are equal, the player with **fewer attempts** wins.
     */
    static func < (lhs: Player, rhs: Player) -> Bool {
        if lhs.totalScore != rhs.totalScore {
            return lhs.totalScore < rhs.totalScore
        }
        return lhs.attempts > rhs.attempts
    }
}
