import Foundation

enum DomainTokens {
    // D-002: commentaire trim + <= 240
    static let commentMaxChars: Int = 240

    // NON DEFINI: la Bible fournie ne fixe pas la borne du titre.
    // Valeur temporaire = 240. Interdiction de modifier sans addendum explicite.
    static let promiTitleMaxChars: Int = 240
}

