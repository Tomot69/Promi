import SwiftUI

struct Brand {
    
    // MARK: - Core Color (vivant, profond, non-flat)
    static let orange = Color(red: 1.0, green: 0.42, blue: 0.0)
    
    // MARK: - Dynamic Layers
    static let orangeGlow = Color(red: 1.0, green: 0.5, blue: 0.1).opacity(0.25)
    static let softHalo = Color.white.opacity(0.04)
    
    // MARK: - Text
    static let textPrimary = Color.primary
    static let textSecondary = Color.primary.opacity(0.5)
    
    // MARK: - Surfaces
    static let ultraThin = Color.white.opacity(0.02)
    static let hairline = Color.white.opacity(0.06)
    
    // MARK: - Karma
    static let karmaExcellent = Color.green
    static let karmaGood = Color.blue
    static let karmaAverage = Color.orange
    static let karmaPoor = Color.red
}
