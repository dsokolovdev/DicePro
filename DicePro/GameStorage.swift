//
//  GameStorage.swift
//  DicePro
//
//  Created by Dmitri  on 03.12.25.
//
import UIKit

final class GameStorage {
    private static let key = "gameData"

    static func save(_ data: GameData) {
        let encoded = try? JSONEncoder().encode(data)
        UserDefaults.standard.set(encoded, forKey: key)
    }

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

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
