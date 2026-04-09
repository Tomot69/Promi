//
//  Nuée.swift
//  Promi
//
//  Phase 1 — Data model only. CloudKit sync arrives in Phase 5.
//

import Foundation

// MARK: - Nuée
//
// A Nuée is a small group of people sharing a swarm of Promis on a common
// theme or in a private intimate circle. It's the social + thematic
// container that lets users create promises together.
//
// A Nuée unifies two dimensions:
//   - Sociale   : a small group (2 to N people)
//   - Visuelle  : a Voronoï swarm of shared Promis on a common theme
//
// A Nuée has a `kind` that determines its tone, default visual treatment,
// and product semantics:
//
//   - .thematic : organizes Promis around a topic. Less intimate, more
//                 about the subject matter. The Nuée name is usually
//                 the theme itself ("Vacances été 2026", "Projet X").
//                 Members share the topic but don't necessarily have a
//                 strong personal bond. Open feel.
//
//   - .intimate : a private inner circle. The group identity itself is
//                 the point — what's shared is shared because of WHO is
//                 there, not WHAT the topic is. Examples: "Mon couple",
//                 "Famille proche", "Mon binôme de toujours". Closed feel.
//
// Nuées can be permanent or ephemeral. An ephemeral Nuée has an
// `expiresAt` date after which it transitions to a read-only archive
// state — its Promis remain visible but no new ones can be added.
//
// === Persistence strategy ===
//
// Phase 1 (this file)  : local persistence via NuéeStore + UserDefaults
// Phase 5 (later)      : CloudKit sync layer added on top, transparent
//                        to the rest of the app
//
// The model is designed to be CloudKit-compatible from day one:
//   - All stored properties use Codable-friendly types
//   - No SwiftUI references in stored properties (moodHint stores the
//     PromiColorMood rawValue as String, decoupled from the View layer)
//   - UUIDs are used everywhere as record identifiers
//   - The struct is Equatable for SwiftUI diffing performance

struct Nuée: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var kind: NuéeKind
    var theme: String?
    var members: [NuéeMember]
    let creatorId: String
    let createdAt: Date
    var expiresAt: Date?

    /// PromiColorMood rawValue as String. Stored as String (not the
    /// enum directly) so the model has zero SwiftUI dependency and
    /// stays serializable in any context, including CloudKit records.
    var moodHintRawValue: String?

    /// SF Symbol name or single emoji character. Optional — the Nuée's
    /// kind provides a sensible default (see `defaultIconGlyph` below).
    var iconGlyph: String?

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
        iconGlyph: String? = nil
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
    }
}

// MARK: - NuéeKind

/// The two product modes a Nuée can take. The kind drives default visual
/// treatment, default copy, and the social tone of the group.
enum NuéeKind: String, Codable, CaseIterable, Identifiable {
    /// "Thematic" — organized around a topic. The Nuée name is typically
    /// the theme. Members share interest in the subject. Open feel.
    case thematic

    /// "Intimate" — a private inner circle. The group itself is the
    /// point. Members share a personal bond. Closed feel.
    case intimate

    var id: String { rawValue }

    /// Default SF Symbol for this kind, used when the user has not
    /// chosen a custom iconGlyph for their Nuée.
    var defaultIconGlyph: String {
        switch self {
        case .thematic: return "tag"
        case .intimate: return "lock.heart"
        }
    }
}

// MARK: - NuéeMember

/// A single participant in a Nuée. Members can be in different states
/// (invited / joined / left) — Phase 1 only models joined and pending
/// invitations.
struct NuéeMember: Identifiable, Codable, Equatable {
    /// The participant's user identifier. For local users this is
    /// `userStore.localUserId`. For invited-but-not-yet-joined members,
    /// this is a temporary invitation token until they accept.
    let id: String

    var displayName: String
    var joinedAt: Date

    /// True once the member has accepted the invitation. False during
    /// the pending state where an invitation has been sent but not
    /// yet acted on.
    var hasAccepted: Bool

    init(
        id: String,
        displayName: String,
        joinedAt: Date = Date(),
        hasAccepted: Bool = true
    ) {
        self.id = id
        self.displayName = displayName
        self.joinedAt = joinedAt
        self.hasAccepted = hasAccepted
    }
}

// MARK: - Computed helpers (presentation prep, no SwiftUI)

extension Nuée {
    /// True if the Nuée has an expiration date set, regardless of
    /// whether it has actually expired yet.
    var isEphemeral: Bool {
        expiresAt != nil
    }

    /// True if the Nuée has expired and should be in read-only mode.
    var isExpired: Bool {
        guard let expiresAt else { return false }
        return Date() >= expiresAt
    }

    /// Days remaining before expiration (positive integer), or nil if
    /// the Nuée is permanent. Returns 0 if already expired.
    var daysRemaining: Int? {
        guard let expiresAt else { return nil }
        let days = Calendar.current.dateComponents(
            [.day],
            from: Date(),
            to: expiresAt
        ).day ?? 0
        return max(0, days)
    }

    /// The icon to display for this Nuée — the user's custom one if
    /// set, otherwise the kind's default.
    var displayIconGlyph: String {
        iconGlyph?.isEmpty == false ? iconGlyph! : kind.defaultIconGlyph
    }

    /// True if the given user is a member of this Nuée (accepted or not).
    func includes(userId: String) -> Bool {
        members.contains { $0.id == userId }
    }

    /// True if the given user has actually joined (not just been invited).
    func hasJoined(userId: String) -> Bool {
        members.contains { $0.id == userId && $0.hasAccepted }
    }

    /// Active members count (those who have accepted), excluding pending.
    var activeMemberCount: Int {
        members.filter(\.hasAccepted).count
    }

    /// Total members count including pending invitations.
    var totalMemberCount: Int {
        members.count
    }

    /// Localized subtitle describing the Nuée's state. Used in list rows
    /// and detail headers. Provided here (not in the View layer) so the
    /// same copy is reusable across multiple presentation contexts.
    func localizedSubtitle(isEnglish: Bool) -> String {
        let kindLabel: String
        switch kind {
        case .thematic:
            kindLabel = isEnglish ? "Thematic" : "Thématique"
        case .intimate:
            kindLabel = isEnglish ? "Intimate" : "Intime"
        }

        let count = activeMemberCount
        let memberWord: String
        if isEnglish {
            memberWord = count <= 1 ? "member" : "members"
        } else {
            memberWord = count <= 1 ? "membre" : "membres"
        }

        let memberSegment = "\(count) \(memberWord)"

        if let days = daysRemaining {
            if days <= 0 {
                let expired = isEnglish ? "expired" : "expirée"
                return "\(kindLabel) · \(memberSegment) · \(expired)"
            }
            let dayLabel = isEnglish
                ? (days == 1 ? "day left" : "days left")
                : (days == 1 ? "jour restant" : "jours restants")
            return "\(kindLabel) · \(memberSegment) · \(days) \(dayLabel)"
        }

        return "\(kindLabel) · \(memberSegment)"
    }
}
