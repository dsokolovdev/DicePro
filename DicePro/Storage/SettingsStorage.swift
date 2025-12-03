//
//  SettingsStorage.swift
//  DicePro
//
//  Created by Dmitri on 03.12.25.
//

import UIKit

// MARK: - SettingsStorage
/// Handles saving and loading user settings using UserDefaults.
/// Settings is encoded/decoded using JSONEncoder/JSONDecoder.
final class SettingsStorage {
    
    // MARK: - Keys
    private static let key = "userSettings"
    
    // MARK: - Save
    /// Saves Settings to UserDefaults.
    static func save(_ settings: Settings) {
        let data = try? JSONEncoder().encode(settings)
        UserDefaults.standard.set(data, forKey: key)
    }
    
    // MARK: - Load
    /// Loads saved Settings or returns default values if none exist.
    static func load() -> Settings {
        guard let data = UserDefaults.standard.data(forKey: key),
              let saved = try? JSONDecoder().decode(Settings.self, from: data) else {
            return Settings.defaults
        }
        return saved
    }
}
