//
//  SettingsStorage.swift
//  DicePro
//
//  Created by Dmitri  on 03.12.25.
//
import UIKit

final class SettingsStorage {
    private static let key = "userSettings"

    static func save(_ settings: Settings) {
        let data = try? JSONEncoder().encode(settings)
        UserDefaults.standard.set(data, forKey: key)
    }

    static func load() -> Settings {
        guard let data = UserDefaults.standard.data(forKey: key),
              let saved = try? JSONDecoder().decode(Settings.self, from: data) else {
            return Settings.defaults
        }
        return saved
    }
}
