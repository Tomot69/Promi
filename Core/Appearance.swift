//
//  Appearance.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

// MARK: - Color Palette
enum ColorPalette: String, Codable, CaseIterable {
    case pureWhite = "Pure White"
    case softCream = "Soft Cream"
    case lightGray = "Light Gray"
    case warmBeige = "Warm Beige"
    case coolMist = "Cool Mist"
    case deepCharcoal = "Deep Charcoal"
    case midnightBlue = "Midnight Blue"
    case forestGreen = "Forest Green"
    
    var name: String {
        return self.rawValue
    }
    
    var backgroundColor: Color {
        switch self {
        case .pureWhite:
            return Color.white
        case .softCream:
            return Color(red: 0.98, green: 0.97, blue: 0.95)
        case .lightGray:
            return Color(red: 0.95, green: 0.95, blue: 0.95)
        case .warmBeige:
            return Color(red: 0.96, green: 0.94, blue: 0.90)
        case .coolMist:
            return Color(red: 0.94, green: 0.96, blue: 0.97)
        case .deepCharcoal:
            return Color(red: 0.15, green: 0.15, blue: 0.15)
        case .midnightBlue:
            return Color(red: 0.10, green: 0.12, blue: 0.18)
        case .forestGreen:
            return Color(red: 0.12, green: 0.16, blue: 0.14)
        }
    }
    
    var textPrimaryColor: Color {
        switch self {
        case .pureWhite, .softCream, .lightGray, .warmBeige, .coolMist:
            return Color.black
        case .deepCharcoal, .midnightBlue, .forestGreen:
            return Color.white
        }
    }
    
    var textSecondaryColor: Color {
        switch self {
        case .pureWhite, .softCream, .lightGray, .warmBeige, .coolMist:
            return Color.black.opacity(0.55)
        case .deepCharcoal, .midnightBlue, .forestGreen:
            return Color.white.opacity(0.55)
        }
    }
}
