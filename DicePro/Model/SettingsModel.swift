//
//  SettingsModel.swift
//  DicePro
//
//  Created by Dmitri  on 02.12.25.
//
import UIKit

struct Settings {
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
}
