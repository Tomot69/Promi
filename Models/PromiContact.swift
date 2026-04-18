import Foundation

// MARK: - PromiContact
//
// Une personne connue de l'utilisateur, accumulée au fil des Nuées et
// des Promi qu'il crée. Pour l'instant, identifiée localement par un
// UUID. Quand Sign in with Apple sera actif (Apple Dev payé), chaque
// contact gagnera son `appleUserId` quand l'invitation sera acceptée
// — l'UUID local sert de pont stable d'ici là.

struct PromiContact: Identifiable, Codable, Equatable, Sendable {
    let id: String              // UUID string, stable pour toute la vie locale
    var displayName: String     // prénom ou surnom tel qu'écrit par l'utilisateur
    let firstSeenAt: Date       // première saisie, sert de fallback de tri
    var lastUsedAt: Date        // mis à jour à chaque réutilisation, tri par récence
    var appleUserId: String?    // null tant qu'Apple Dev pas actif

    /// Date de blocage. `nil` = contact non bloqué (état par défaut).
    /// Quand non-nil, tous les Promi reçus de ce contact sont masqués
    /// dans la home, ses Nuées partagées sont masquées, et il ne peut
    /// plus apparaître dans les pickers POUR QUI / AVEC QUI.
    /// Réversible via debloquer() qui remet à nil.
    var blockedAt: Date?

    /// Motif de blocage saisi par l'utilisateur (optionnel). Sert de
    /// rappel mémoriel si l'utilisateur consulte sa liste de bloqués
    /// dans Settings — il sait pourquoi il a bloqué cette personne.
    var blockReason: String?

    init(
        id: String = UUID().uuidString,
        displayName: String,
        firstSeenAt: Date = Date(),
        lastUsedAt: Date = Date(),
        appleUserId: String? = nil,
        blockedAt: Date? = nil,
        blockReason: String? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.firstSeenAt = firstSeenAt
        self.lastUsedAt = lastUsedAt
        self.appleUserId = appleUserId
        self.blockedAt = blockedAt
        self.blockReason = blockReason
    }

    /// Décodage backward-compatible : un PromiContact persisté avant
    /// l'ajout des champs blockedAt/blockReason se décode avec ces
    /// champs à nil (= non bloqué). Aucune migration de données nécessaire.
    enum CodingKeys: String, CodingKey {
        case id, displayName, firstSeenAt, lastUsedAt, appleUserId
        case blockedAt, blockReason
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decode(String.self, forKey: .id)
        self.displayName = try c.decode(String.self, forKey: .displayName)
        self.firstSeenAt = try c.decode(Date.self, forKey: .firstSeenAt)
        self.lastUsedAt = try c.decode(Date.self, forKey: .lastUsedAt)
        self.appleUserId = try c.decodeIfPresent(String.self, forKey: .appleUserId)
        self.blockedAt = try c.decodeIfPresent(Date.self, forKey: .blockedAt)
        self.blockReason = try c.decodeIfPresent(String.self, forKey: .blockReason)
    }

    /// Convenience accessor : true si ce contact est actuellement bloqué.
    var isBlocked: Bool { blockedAt != nil }
}

extension PromiContact {
    /// Conversion vers NuéeMember pour pouvoir ajouter un contact comme
    /// membre d'une Nuée sans dupliquer les types. Le hasAccepted reste
    /// false tant qu'on n'a pas de système d'invitation réel.
    func asNuéeMember() -> NuéeMember {
        NuéeMember(
            id: appleUserId ?? id,
            displayName: displayName,
            joinedAt: Date(),
            hasAccepted: false
        )
    }
}
