import Foundation

nonisolated struct Nuée: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var name: String
    var kind: NuéeKind
    var theme: String?
    var members: [NuéeMember]
    let creatorId: String
    let createdAt: Date
    var expiresAt: Date?
    var moodHintRawValue: String?
    var iconGlyph: String?
    /// ID de la Nuée parente. `nil` = Nuée top-level (affichée dans
    /// MesNuées). Non-nil = sous-Nuée thématique à l'intérieur d'une
    /// Nuée intime (affichée dans le detail de la parente, pas dans
    /// MesNuées). Backward-compatible : JSON sans ce champ → nil.
    var parentNuéeId: UUID?
    var version: Int
    var lastModified: Date

    init(
        id: UUID = UUID(),
        name: String,
        kind: NuéeKind = .thematic,
        theme: String? = nil,
        members: [NuéeMember] = [],
        creatorId: String,
        createdAt: Date = Date(),
        expiresAt: Date? = nil,
        moodHintRawValue: String? = nil,
        iconGlyph: String? = nil,
        parentNuéeId: UUID? = nil,
        version: Int = 1,
        lastModified: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.theme = theme
        self.members = members
        self.creatorId = creatorId
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.moodHintRawValue = moodHintRawValue
        self.iconGlyph = iconGlyph
        self.parentNuéeId = parentNuéeId
        self.version = version
        self.lastModified = lastModified
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, kind, theme, members, creatorId, createdAt
        case expiresAt, moodHintRawValue, iconGlyph, parentNuéeId
        case version, lastModified
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decode(UUID.self, forKey: .id)
        self.name = try c.decode(String.self, forKey: .name)
        self.kind = try c.decode(NuéeKind.self, forKey: .kind)
        self.theme = try c.decodeIfPresent(String.self, forKey: .theme)
        self.members = try c.decode([NuéeMember].self, forKey: .members)
        self.creatorId = try c.decode(String.self, forKey: .creatorId)
        self.createdAt = try c.decode(Date.self, forKey: .createdAt)
        self.expiresAt = try c.decodeIfPresent(Date.self, forKey: .expiresAt)
        self.moodHintRawValue = try c.decodeIfPresent(String.self, forKey: .moodHintRawValue)
        self.iconGlyph = try c.decodeIfPresent(String.self, forKey: .iconGlyph)
        self.parentNuéeId = try c.decodeIfPresent(UUID.self, forKey: .parentNuéeId)
        self.version = try c.decodeIfPresent(Int.self, forKey: .version) ?? 1
        self.lastModified = try c.decodeIfPresent(Date.self, forKey: .lastModified) ?? Date()
    }
}

extension Nuée: SyncableEntity {}

nonisolated enum NuéeKind: String, Codable, CaseIterable, Identifiable, Sendable {
    case thematic
    case intimate
    var id: String { rawValue }
    var defaultIconGlyph: String {
        switch self {
        case .thematic: return "circle.hexagongrid.fill"
        case .intimate: return "hands.sparkles.fill"
        }
    }
}

nonisolated struct NuéeMember: Identifiable, Codable, Equatable, Sendable {
    let id: String
    var displayName: String
    var joinedAt: Date
    var hasAccepted: Bool
    init(id: String, displayName: String, joinedAt: Date = Date(), hasAccepted: Bool = true) {
        self.id = id; self.displayName = displayName; self.joinedAt = joinedAt; self.hasAccepted = hasAccepted
    }
}

extension Nuée {
    /// True si c'est une sous-Nuée thématique rattachée à une Intime.
    var isChildThematic: Bool { parentNuéeId != nil }
    /// True si c'est une Nuée top-level (affichée dans MesNuées).
    var isTopLevel: Bool { parentNuéeId == nil }
    var isEphemeral: Bool { expiresAt != nil }
    var isExpired: Bool {
        guard let expiresAt else { return false }
        return Date() >= expiresAt
    }
    var daysRemaining: Int? {
        guard let expiresAt else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: expiresAt).day ?? 0
        return max(0, days)
    }
    var displayIconGlyph: String { iconGlyph?.isEmpty == false ? iconGlyph! : kind.defaultIconGlyph }
    func includes(userId: String) -> Bool { members.contains { $0.id == userId } }
    func hasJoined(userId: String) -> Bool { members.contains { $0.id == userId && $0.hasAccepted } }
    var activeMemberCount: Int { members.filter(\.hasAccepted).count }
    var totalMemberCount: Int { members.count }

    func localizedSubtitle(isEnglish: Bool) -> String {
        let kindLabel: String
        switch kind {
        case .thematic: kindLabel = isEnglish ? "Thematic" : "Thématique"
        case .intimate: kindLabel = isEnglish ? "Intimate" : "Intime"
        }
        let count = activeMemberCount
        let memberWord: String
        if isEnglish { memberWord = count <= 1 ? "member" : "members" }
        else { memberWord = count <= 1 ? "membre" : "membres" }
        let memberSegment = "\(count) \(memberWord)"
        if let days = daysRemaining {
            if days <= 0 {
                let expired = isEnglish ? "expired" : "expirée"
                return "\(kindLabel) · \(memberSegment) · \(expired)"
            }
            let dayLabel = isEnglish ? (days == 1 ? "day left" : "days left") : (days == 1 ? "jour restant" : "jours restants")
            return "\(kindLabel) · \(memberSegment) · \(days) \(dayLabel)"
        }
        return "\(kindLabel) · \(memberSegment)"
    }
}
