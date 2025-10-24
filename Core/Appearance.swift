//
//  Appearance.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

// MARK: - Palette Enum
enum Palette: String, CaseIterable, Identifiable {
    case promi
    case lavender
    case sage
    case powder
    case marseilleSunrise
    case pastisHour
    case unicornTears
    case cosmicVoid
    case catNebula
    case shibui
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .promi: return "Promi"
        case .lavender: return "Lavender"
        case .sage: return "Sage"
        case .powder: return "Powder"
        case .marseilleSunrise: return "Marseille Sunrise"
        case .pastisHour: return "Pastis Hour"
        case .unicornTears: return "Unicorn Tears"
        case .cosmicVoid: return "Cosmic Void"
        case .catNebula: return "Cat Nebula"
        case .shibui: return "Shibui"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .promi: return Brand.orange
        case .lavender: return Color(hex: "#C9C6F5")
        case .sage: return Color(hex: "#CFE4D6")
        case .powder: return Color(hex: "#F2C6D8")
        case .marseilleSunrise: return Color(hex: "#FF9A76")
        case .pastisHour: return Color(hex: "#FFF4A3")
        case .unicornTears: return Color(hex: "#E0C3FC")
        case .cosmicVoid: return Color(hex: "#2C2C3E")
        case .catNebula: return Color(hex: "#9D84B7")
        case .shibui: return Color(hex: "#F5F5DC")
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .promi: return Brand.backgroundLight
        case .lavender: return Color(hex: "#F2F1FB")
        case .sage: return Color(hex: "#F3F8F5")
        case .powder: return Color(hex: "#FDF5F7")
        case .marseilleSunrise: return Color(hex: "#FFF0EB")
        case .pastisHour: return Color(hex: "#FFFEF5")
        case .unicornTears: return Color(hex: "#F9F5FF")
        case .cosmicVoid: return Color(hex: "#1A1A2E")
        case .catNebula: return Color(hex: "#2E2740")
        case .shibui: return Color(hex: "#0A0A0A")
        }
    }
    
    var unlockRequirement: UnlockRequirement {
        switch self {
        case .promi, .lavender, .sage, .powder:
            return .free
        case .marseilleSunrise:
            return .karma(200)
        case .pastisHour:
            return .purchase(price: "1,99€", productId: "promi.palette.pastis")
        case .unicornTears:
            return .purchase(price: "3,99€", productId: "promi.palette.unicorn")
        case .cosmicVoid:
            return .purchase(price: "7,99€", productId: "promi.palette.cosmic")
        case .catNebula:
            return .purchase(price: "4,99€", productId: "promi.palette.catnebula")
        case .shibui:
            return .secret(karma: 500, badge: "shibuiUnlocked")
        }
    }
}

// MARK: - Unlock Requirement
enum UnlockRequirement {
    case free
    case karma(Int)
    case purchase(price: String, productId: String)
    case secret(karma: Int, badge: String)
}
