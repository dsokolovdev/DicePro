//
//  Constants.swift
//  DicePro
//
//  Created by Dmitri  on 30.11.25.
//

import UIKit

// MARK: - Screen Classes
/// Categorizes devices for UI scaling.
enum ScreenClass {
    case se
    case mini
    case normal
    case proMax
    case iPad
}

/// Returns the current device class used for adaptive UI sizing.
var screenClass: ScreenClass {
    if UIDevice.current.userInterfaceIdiom == .pad {
        return .iPad
    }
    
    let h = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
    
    switch h {
    case ..<700:    return .se
    case 700..<830: return .mini
    case 830..<900: return .normal
    default:        return .proMax
    }
}

// MARK: - Scale Factor
/// Global UI scale factor based on device class.
/// Used across the app to proportionally size elements.
var scaleFactor: CGFloat {
    switch screenClass {
    case .se:     return 0.86
    case .mini:   return 0.95
    case .normal: return 1.0
    case .proMax: return 1.08
    case .iPad:   return 1.18
    }
}
