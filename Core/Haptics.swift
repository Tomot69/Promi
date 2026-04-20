//
//  Haptics.swift
//  Promi
//
//  Created on 25/10/2025.
//

import UIKit
import AudioToolbox

class Haptics {
    static let shared = Haptics()
    
    private init() {}
    
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func lightTap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func tinyPop() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred(intensity: 0.3)
    }
    
    func gentleNudge() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred(intensity: 0.5)
    }
    /// Son signature "tenu" — une note courte et satisfaisante.
        /// Utilise le son système iOS 'Tink' (intégré, pas besoin de fichier).
        func playKeptSound() {
            AudioServicesPlaySystemSound(1057) // Tink
        }
}
