//
//  Appearance.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

// MARK: - Palette Enum (ÉTENDU + NOUVEAUX PACKS)
enum Palette: String, CaseIterable, Identifiable {
    // Gratuits
    case promi
    case lavender
    case sage
    case powder
    
    // Karma
    case marseilleSunrise
    case midnight
    case forest
    
    // Payants
    case pastisHour
    case unicornTears
    case bubblegum
    case cosmicVoid
    case catNebula
    case goldenHour
    
    // Secret
    case shibui
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .promi: return "Promi"
        case .lavender: return "Lavender Dream"
        case .sage: return "Sage Whisper"
        case .powder: return "Powder Puff"
        case .marseilleSunrise: return "Marseille Sunrise"
        case .midnight: return "Midnight Oil"
        case .forest: return "Forest Bathing"
        case .pastisHour: return "Pastis Hour"
        case .unicornTears: return "Unicorn Tears"
        case .bubblegum: return "Bubblegum Pop"
        case .cosmicVoid: return "Cosmic Void"
        case .catNebula: return "Cat Nebula"
        case .goldenHour: return "Golden Hour"
        case .shibui: return "Shibui"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .promi: return Brand.orange
        case .lavender: return Color(hex: "#C9C6F5")
        case .sage: return Color(hex: "#A8D5BA")
        case .powder: return Color(hex: "#F2C6D8")
        case .marseilleSunrise: return Color(hex: "#FF9A76")
        case .midnight: return Color(hex: "#4A5D7C")
        case .forest: return Color(hex: "#5F7A61")
        case .pastisHour: return Color(hex: "#F4D03F")
        case .unicornTears: return Color(hex: "#E0C3FC")
        case .bubblegum: return Color(hex: "#FF6B9D")
        case .cosmicVoid: return Color(hex: "#2C2C3E")
        case .catNebula: return Color(hex: "#9D84B7")
        case .goldenHour: return Color(hex: "#FFB347")
        case .shibui: return Color(hex: "#F5F5DC")
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .promi: return Color(hex: "#FAFAFA")
        case .lavender: return Color(hex: "#F2F1FB")
        case .sage: return Color(hex: "#F3F8F5")
        case .powder: return Color(hex: "#FDF5F7")
        case .marseilleSunrise: return Color(hex: "#FFF0EB")
        case .midnight: return Color(hex: "#1E2A3A")
        case .forest: return Color(hex: "#E8F5E9")
        case .pastisHour: return Color(hex: "#FFFEF5")
        case .unicornTears: return Color(hex: "#F9F5FF")
        case .bubblegum: return Color(hex: "#FFF0F5")
        case .cosmicVoid: return Color(hex: "#1A1A2E")
        case .catNebula: return Color(hex: "#2E2740")
        case .goldenHour: return Color(hex: "#FFF8E7")
        case .shibui: return Color(hex: "#0A0A0A")
        }
    }
    
    var textPrimaryColor: Color {
        switch self {
        case .midnight, .cosmicVoid, .catNebula, .shibui:
            return Color(hex: "#FAFAFA") // Texte clair sur fond sombre
        default:
            return Brand.textPrimary // Texte sombre sur fond clair
        }
    }
    
    var textSecondaryColor: Color {
        switch self {
        case .midnight, .cosmicVoid, .catNebula, .shibui:
            return Color(hex: "#B0B0B0") // Texte secondaire clair
        default:
            return Brand.textSecondary // Texte secondaire sombre
        }
    }
    
    var unlockRequirement: UnlockRequirement {
        switch self {
        case .promi, .lavender, .sage, .powder:
            return .free
        case .marseilleSunrise:
            return .karma(200)
        case .midnight:
            return .karma(150)
        case .forest:
            return .karma(100)
        case .pastisHour:
            return .purchase(price: "1,99€", productId: "promi.palette.pastis")
        case .unicornTears:
            return .purchase(price: "3,99€", productId: "promi.palette.unicorn")
        case .bubblegum:
            return .purchase(price: "2,99€", productId: "promi.palette.bubblegum")
        case .cosmicVoid:
            return .purchase(price: "7,99€", productId: "promi.palette.cosmic")
        case .catNebula:
            return .purchase(price: "4,99€", productId: "promi.palette.catnebula")
        case .goldenHour:
            return .purchase(price: "2,99€", productId: "promi.palette.golden")
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
