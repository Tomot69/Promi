import Foundation

enum ReactionRules {

    static func ensureSingleBravo(_ type: ReactionType) throws {
        // INV-004: uniquement "bravo" est autorisé ici ; l’unicité est portée par SocialRules via BravoKey.
        if type != .bravo {
            throw PromiError.validation(.outOfRange(min: 0, max: 0, got: 1))
        }
    }
}

