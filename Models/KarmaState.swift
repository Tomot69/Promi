//
//  KarmaState.swift
//  Promi
//
//  Created on 24/10/2025.
//

import Foundation

// MARK: - Karma State
struct KarmaState: Codable {
    var percentage: Int // 0–100
    var earnedBadges: Set<Badge>
    
    init(percentage: Int = 100, earnedBadges: Set<Badge> = []) {
        self.percentage = max(0, min(100, percentage))
        self.earnedBadges = earnedBadges
    }
}

// MARK: - Badge
enum Badge: Int, CaseIterable, Codable {
    case reliable = 100
    case consistent = 200
    case trustKeeper = 300
    case senseiOfPromises = 400
    case shibuiUnlocked = 500
    
    var title: String {
        switch self {
        case .reliable: return "Reliable"
        case .consistent: return "Consistent"
        case .trustKeeper: return "Trust Keeper"
        case .senseiOfPromises: return "Sensei of Promises"
        case .shibuiUnlocked: return "Shibui Unlocked"
        }
    }
    
    var description: String {
        switch self {
        case .reliable: return "Tu as atteint 100 Karma"
        case .consistent: return "Tu as atteint 200 Karma"
        case .trustKeeper: return "Tu as atteint 300 Karma"
        case .senseiOfPromises: return "Tu as atteint 400 Karma"
        case .shibuiUnlocked: return "Tu as atteint 500 Karma - Thème secret débloqué"
        }
    }
}
