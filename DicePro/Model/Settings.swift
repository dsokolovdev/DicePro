//
//  SettingsModel.swift
//  DicePro
//
//  Created by Dmitri on 02.12.25.
//

import UIKit

// MARK: - Settings Model
/// Stores user game settings and supports persistence (Codable).
struct Settings: Codable {
    
    // MARK: - User Options
    /// Enables 3rd player.
    var isPlayer3Enabled: Bool
    
    /// Enables 4th player.
    var isPlayer4Enabled: Bool
    
    /// Enables rolling with two dices instead of one.
    var isTwoDicesEnabled: Bool
    
    /// Prevents the device screen from dimming or locking.
    var isScreenAlwaysOnEnabled: Bool
    
    
    // MARK: - Default Settings
    /// The initial default configuration for all settings.
    static let defaults = Settings(
        isPlayer3Enabled: false,
        isPlayer4Enabled: false,
        isTwoDicesEnabled: false,
        isScreenAlwaysOnEnabled: false
    )
    
    
    // MARK: - State Validation
    /// Returns true when all current settings match the default values.
    var isDefault: Bool {
        return (
            self.isPlayer3Enabled == Settings.defaults.isPlayer3Enabled &&
            self.isPlayer4Enabled == Settings.defaults.isPlayer4Enabled &&
            self.isTwoDicesEnabled == Settings.defaults.isTwoDicesEnabled &&
            self.isScreenAlwaysOnEnabled == Settings.defaults.isScreenAlwaysOnEnabled
        )
    }
    
    
    // MARK: - Footer Text
    /// Returns formatted version/build info for displaying at the bottom of Settings screen.
    static var settingsFooterText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        
        return """
            DicePro
            Version: \(version) (\(build))
            Made with ❤️  by D.S.
            © 2025
            """
    }
}
