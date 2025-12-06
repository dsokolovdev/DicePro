//
//  DiceModel.swift
//  DicePro
//
//  Created by Dmitri on 30.11.25.
//

import UIKit

// MARK: - Dice Model
/// Core logic for dice rolling, score tracking and reset functionality.
/// Works together with `GameData` and `Player` models.
struct DiceModel  {
    
    // MARK: - Dice Types
    /// Available dice color themes with their mapped image sets.
    enum Dices {
        case blackYellow, blackRed, BlueGrey, WhiteBlue
        
        /// Returns an array of dice face image names for the selected theme.
        var diceArray: [String] {
            switch self {
            case .BlueGrey:
                return ["DiceBlueGrey1", "DiceBlueGrey2", "DiceBlueGrey3",
                        "DiceBlueGrey4", "DiceBlueGrey5", "DiceBlueGrey6"]
                
            case .WhiteBlue:
                return ["DiceWhiteBlue1", "DiceWhiteBlue2", "DiceWhiteBlue3",
                        "DiceWhiteBlue4", "DiceWhiteBlue5", "DiceWhiteBlue6"]
                
            case .blackRed:
                return ["DiceBlackRed1", "DiceBlackRed2", "DiceBlackRed3",
                        "DiceBlackRed4", "DiceBlackRed5", "DiceBlackRed6"]
                
            case .blackYellow:
                return ["DiceBlackYellow1", "DiceBlackYellow2", "DiceBlackYellow3",
                        "DiceBlackYellow4", "DiceBlackYellow5", "DiceBlackYellow6"]
            }
        }
    }
    
    
    // MARK: - Stored Game Data
    /// Tracks all players and their scores.
    var data: GameData = GameData(players: [
        Player(name: Players.player1.name),
        Player(name: Players.player2.name)
    ])
    
    
    // MARK: - Score State
    /// Indicates whether any player already has non-zero score or attempts.
    var hasScores: Bool {
        return data.players.contains { $0.totalScore > 0 || $0.attempts > 0 }
    }
    
    
    // MARK: - Dice Roll
    /// Returns a random number in range 0...5 (representing dice index).
    func roll() -> Int {
        Int.random(in: 0...5)
    }
    
    
    // MARK: - Ranking
    /// Updates player rankings via GameData's ranking logic.
    mutating func updateRanks() {
        data.updateRanks()
    }
    
    
    // MARK: - Dice Image Mapping
    /// Returns an image name for a specific score and selected dice theme.
    func setDice(score: Int, color: Dices) -> String {
        let dice = color.diceArray
        return dice[score]
    }
    
    
    // MARK: - Reset Scores
    /// Resets all players’ game statistics to zero.
    mutating func resetAllScores() {
        if hasScores {
            for i in data.players.indices {
                data.players[i].totalScore = 0
                data.players[i].currentScore = 0
                data.players[i].attempts = 0
                data.players[i].rank = 0
            }
        }
    }
}
