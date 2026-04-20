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

    /// Haptic spécifique au pack visuel quand on tape une cellule.
    func packTap(_ pack: String) {
        switch pack {
        case "galets":
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.35)
        case "alveolesSignature":
            UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.5)
        case "mosaicFlat":
            UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.4)
        case "spectrumSoft":
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.6)
        case "cristal":
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.45)
        case "vitrailChrome":
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.55)
        case "trame":
            UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.3)
        default:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
    /// Son signature "tenu" — une note courte et satisfaisante.
        /// Utilise le son système iOS 'Tink' (intégré, pas besoin de fichier).
        func playKeptSound() {
            AudioServicesPlaySystemSound(1057) // Tink
        }
}
