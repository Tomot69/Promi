//
//  Brand.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

// MARK: - Brand Colors
struct Brand {
    // Orange Promi (immuable)
    static let orange = Color(hex: "#FF5733")
    
    // Texte
    static let textPrimary = Color(hex: "#1A1A1A")
    static let textSecondary = Color(hex: "#8E8E93")
    
    // Fond
    static let backgroundLight = Color(hex: "#FAFAFA")
    static let backgroundDark = Color(hex: "#1C1C1E")
    
    // États Karma
    static let karmaExcellent = Color.green
    static let karmaGood = Color.yellow
    static let karmaAverage = Color.orange
    static let karmaPoor = Color.red
}

// MARK: - Spacing Scale
enum Spacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Typography Scale
enum Typography {
    // Titres
    static let title1 = Font.system(size: 28, weight: .semibold)
    static let title2 = Font.system(size: 22, weight: .semibold)
    static let title3 = Font.system(size: 20, weight: .semibold)
    
    // Corps
    static let body = Font.system(size: 16, weight: .regular)
    static let bodyEmphasis = Font.system(size: 16, weight: .medium)
    static let callout = Font.system(size: 14, weight: .regular)
    
    // Détails
    static let caption = Font.system(size: 12, weight: .regular)
    static let caption2 = Font.system(size: 11, weight: .regular)
}

// MARK: - Corner Radius Scale
enum CornerRadius {
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let full: CGFloat = 9999
}

// MARK: - Opacity Scale
enum Opacity {
    static let invisible: Double = 0.0
    static let disabled: Double = 0.4
    static let secondary: Double = 0.6
    static let translucent: Double = 0.8
    static let opaque: Double = 1.0
}

// MARK: - Animation Presets
enum AnimationPreset {
    static let spring = Animation.spring(response: 0.28, dampingFraction: 0.9)
    static let springSlow = Animation.spring(response: 0.35, dampingFraction: 0.95)
    static let springBouncy = Animation.spring(response: 0.25, dampingFraction: 0.7)
    static let easeOut = Animation.easeOut(duration: 0.3)
    static let easeInOut = Animation.easeInOut(duration: 0.25)
}

// MARK: - Color Extension (Hex support)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
