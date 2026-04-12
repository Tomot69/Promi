import Foundation

// MARK: - Nuée Draft Model
//
// Mirrors PromiDraft but for Nuée fields. Saved when the user quits
// CreateNuéeView without confirming — same UX as Promi drafts.
// Foundation-only (no SwiftUI import) for CloudKit compatibility.

struct NuéeDraft: Identifiable, Codable {
    let id: UUID
    var name: String
    var kind: NuéeKind
    var theme: String?
    var moodHintRawValue: String?
    var expiresAt: Date?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String = "",
        kind: NuéeKind = .thematic,
        theme: String? = nil,
        moodHintRawValue: String? = nil,
        expiresAt: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.theme = theme
        self.moodHintRawValue = moodHintRawValue
        self.expiresAt = expiresAt
        self.createdAt = createdAt
    }
}
