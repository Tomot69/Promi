import SwiftUI

struct Brand {
    
    // MARK: - Core Color (signature Promi — warm, luminous, recognizable)
    //
    // This is THE brand color of Promi. It appears in every title accent,
    // every CTA button, every tutorial arrow, every onboarding highlight.
    // Value: (0.98, 0.56, 0.22) — a warm amber-orange that reads as
    // optimistic and sincere, never aggressive or corporate.
    //
    // Previously duplicated as `private let brandOrange` in ~16 files.
    // Now unified here as the single source of truth.
    static let orange = Color(red: 0.98, green: 0.56, blue: 0.22)
    
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
    
    /// Karma threshold just crossed — used by the field pulse easter egg.
        static func karmaJustCrossedThreshold(old: Int, new: Int) -> Int? {
            let thresholds = [50, 75, 100]
            for t in thresholds {
                if old < t && new >= t { return t }
            }
            return nil
        }
}

// MARK: - Shake detection via UIWindow override

extension Notification.Name {
    static let promiShakeDetected = Notification.Name("promiShakeDetected")
}

struct ShakeDetectorView: UIViewRepresentable {
    func makeUIView(context: Context) -> ShakeDetectingUIView { ShakeDetectingUIView() }
    func updateUIView(_ uiView: ShakeDetectingUIView, context: Context) {}
}

class ShakeDetectingUIView: UIView {
    override var canBecomeFirstResponder: Bool { true }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        becomeFirstResponder()
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            NotificationCenter.default.post(name: .promiShakeDetected, object: nil)
        }
    }
}
