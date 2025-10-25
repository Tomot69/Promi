//
//  Brand.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

struct Brand {
    // Orange signature (plus invitant)
    static let orange = Color(red: 1.0, green: 0.45, blue: 0.0) // #FF7300
    
    // Textes (opacités augmentées pour lisibilité)
    static let textPrimary = Color.black
    static let textSecondary = Color.black.opacity(0.55) // Avant: 0.4 → Maintenant: 0.55
    
    // Karma colors
    static let karmaExcellent = Color.green
    static let karmaGood = Color.blue
    static let karmaAverage = Color.orange
    static let karmaPoor = Color.red
}
