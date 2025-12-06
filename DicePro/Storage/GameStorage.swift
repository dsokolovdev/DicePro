//
//  GameStorage.swift
//  DicePro
//
//  Created by Dmitri on 03.12.25.
//

import UIKit

// MARK: - GameStorage
/// Handles saving, loading, and clearing persistent game data using UserDefaults.
/// GameData is encoded/decoded using JSONEncoder/JSONDecoder.
final class GameStorage {
    
    // MARK: - Keys
    private static let key = "gameData"
    
    // MARK: - Save
    /// Saves GameData to UserDefaults.
    static func save(_ data: GameData) {
        let encoded = try? JSONEncoder().encode(data)
        UserDefaults.standard.set(encoded, forKey: key)
    }
    
    // MARK: - Load
    /// Loads saved GameData or returns default state if no saved data exists.
    static func load() -> GameData {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode(GameData.self, from: data) else {
            return GameData(players: [
                Player(name: "P1"),
                Player(name: "P2")
            ])
        }
        return decoded
    }
    
    // MARK: - Clear
    /// Removes stored game data from UserDefaults.
    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
