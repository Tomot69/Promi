import Foundation

// MARK: - QuotaConstants
//
// Limites du free tier. Quand Promi Plus est actif (isPremium == true
// dans UserStore), toutes les limites sont levées.
//
// À AJUSTER avant lancement si nécessaire — une seule source de vérité.

enum QuotaConstants {
    /// Nombre max de Promi créables par jour en free tier.
    static let freePromiPerDay: Int = 5

    /// Nombre max de Nuées top-level en free tier (total, pas par jour).
    static let freeNuéesTotal: Int = 2

    /// Prix affichés dans le paywall (indicatifs — le vrai prix est
    /// défini dans App Store Connect via StoreKit). Utilisés uniquement
    /// pour l'affichage dans PromiPlusPaywallView.
    static let monthlyPriceDisplay = "2,99 €"
    static let yearlyPriceDisplay = "19,99 €"
    static let yearlySavingsDisplay = "44 %"
}
