import Foundation

// MARK: - LegalConstants
//
// Constantes centralisées pour les documents légaux. La version est
// utilisée par UserStore.acceptedTermsVersion : si on incrémente cette
// constante après une modification des CGU, l'utilisateur sera obligé
// de re-accepter au prochain lancement.

enum LegalConstants {
    /// Version courante des CGU + Politique de confidentialité.
    /// À INCRÉMENTER à chaque modification substantielle des textes.
    static let currentTermsVersion: Int = 1

    /// URLs publiques GitHub Pages (à mettre à jour quand le repo sera créé).
    /// Ces URLs servent à App Store Connect et au lien "Voir en ligne"
    /// depuis l'app. Les textes complets sont aussi embarqués dans l'app
    /// (LegalDocumentsView) pour consultation hors-ligne.
    static let termsURL = URL(string: "https://tomot69.github.io/legal/terms.html")!
    static let privacyURL = URL(string: "https://tomot69.github.io/legal/privacy.html")!

    /// Identité de l'éditeur — affichée dans les documents légaux et
    /// dans la section "À propos" des Réglages.
    static let editorName = "Tom Autier"
    static let editorStatus = "micro-entrepreneur"
    static let editorAddress = "23 rue Breteuil, 13006 Marseille, France"
    static let editorEmail = "promiapp@gmail.com"
    static let editorCountry = "France"
}
