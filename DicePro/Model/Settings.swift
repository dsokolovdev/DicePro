//
//  SettingsModel.swift
//  DicePro
//
//  Created by Dmitri  on 02.12.25.
//
import UIKit

struct Settings: Codable {
    var isPlayer3Enabled: Bool
    var isPlayer4Enabled: Bool
    var isTwoDicesEnabled: Bool
    var isScreenAlwaysOnEnabled: Bool
    
    static let defaults = Settings(
        isPlayer3Enabled: false,
        isPlayer4Enabled: false,
        isTwoDicesEnabled: false,
        isScreenAlwaysOnEnabled: false
    )
    
    var isDefault: Bool {
        return (self.isPlayer3Enabled == Settings.defaults.isPlayer3Enabled &&
                self.isPlayer4Enabled == Settings.defaults.isPlayer4Enabled &&
                self.isTwoDicesEnabled == Settings.defaults.isTwoDicesEnabled &&
                self.isScreenAlwaysOnEnabled == Settings.defaults.isScreenAlwaysOnEnabled)
    }
    
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
