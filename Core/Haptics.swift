//
//  Haptics.swift
//  Promi
//
//  Created on 24/10/2025.
//

import UIKit

// MARK: - Haptics Manager
class Haptics {
    static let shared = Haptics()
    
    private init() {}
    
    // Success (ronron chaleureux)
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // Light tap (interaction mineure)
    func lightTap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    // Tiny pop (toggle, micro-interaction)
    func tinyPop() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred(intensity: 0.5)
    }
    
    // Gentle nudge (pré-rappel T-30)
    func gentleNudge() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            generator.impactOccurred()
        }
    }
    
    // Selection changed
    func selectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
