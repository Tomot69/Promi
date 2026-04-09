import Foundation

struct PromiItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var dueDate: Date
    var importance: Importance
    var assignee: String?
    var attachments: [Attachment]
    var status: Status
    var intensity: Int
    var kind: PromiKind
    let createdAt: Date
    var completedAt: Date?
    var postponedUntil: Date?

    /// The id of the Nuée this Promi belongs to, or nil if it's a personal
    /// Promi (not part of any group). Backward-compatible: existing JSON
    /// without this field decodes to nil. The JSON key is ASCII ("nueeId")
    /// for cross-platform serialization safety, while the Swift property
    /// name keeps the accent for consistency with the Nuée model.
    var nuéeId: UUID?

    init(
        id: UUID = UUID(),
        title: String,
        dueDate: Date,
        importance: Importance = .normal,
        assignee: String? = nil,
        attachments: [Attachment] = [],
        status: Status = .open,
        intensity: Int = 50,
        kind: PromiKind = .precise,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        postponedUntil: Date? = nil,
        nuéeId: UUID? = nil
    ) {
        self.id = id
        self.title = PromiItem.normalizedTitle(from: title)
        self.dueDate = dueDate
        self.importance = importance
        self.assignee = assignee
        self.attachments = attachments
        self.status = status
        self.intensity = min(max(intensity, 0), 100)
        self.kind = kind
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.postponedUntil = postponedUntil
        self.nuéeId = nuéeId
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case dueDate
        case importance
        case assignee
        case attachments
        case status
        case intensity
        case kind
        case createdAt
        case completedAt
        case postponedUntil
        case nuéeId = "nueeId"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = PromiItem.normalizedTitle(from: try container.decode(String.self, forKey: .title))
        dueDate = try container.decode(Date.self, forKey: .dueDate)
        importance = try container.decode(Importance.self, forKey: .importance)
        assignee = try container.decodeIfPresent(String.self, forKey: .assignee)
        attachments = try container.decodeIfPresent([Attachment].self, forKey: .attachments) ?? []
        status = try container.decode(Status.self, forKey: .status)
        intensity = min(max(try container.decodeIfPresent(Int.self, forKey: .intensity) ?? 50, 0), 100)
        kind = try container.decodeIfPresent(PromiKind.self, forKey: .kind) ?? .precise
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
        postponedUntil = try container.decodeIfPresent(Date.self, forKey: .postponedUntil)
        // Backward-compatible: missing in old JSON → nil. Personal Promi.
        nuéeId = try container.decodeIfPresent(UUID.self, forKey: .nuéeId)
    }

    static let requiredPrefix = "Promi "

    static func normalizedTitle(from raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return requiredPrefix.trimmingCharacters(in: .whitespaces) }

        let lowered = trimmed.lowercased()
        if lowered == "promi" {
            return requiredPrefix.trimmingCharacters(in: .whitespaces)
        }

        if lowered.hasPrefix("promi ") {
            let suffix = String(trimmed.dropFirst(6)).trimmingCharacters(in: .whitespacesAndNewlines)
            return suffix.isEmpty ? requiredPrefix.trimmingCharacters(in: .whitespaces) : requiredPrefix + suffix
        }

        return requiredPrefix + trimmed
    }

    var editorSuffix: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.lowercased().hasPrefix("promi ") {
            return String(trimmed.dropFirst(6)).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if trimmed.lowercased() == "promi" {
            return ""
        }
        return trimmed
    }

    var normalizedDisplayTitle: String {
        PromiItem.normalizedTitle(from: title)
    }
}

enum PromiKind: String, Codable, CaseIterable {
    case precise
    case floating
    case emotional
}

enum Importance: String, Codable, CaseIterable {
    case low
    case normal
    case urgent
}

enum Status: String, Codable {
    case open
    case done
    case postponed
}

struct Attachment: Identifiable, Codable, Equatable {
    let id: UUID
    let type: AttachmentType
    let filename: String
    let localPath: String

    init(id: UUID = UUID(), type: AttachmentType, filename: String, localPath: String) {
        self.id = id
        self.type = type
        self.filename = filename
        self.localPath = localPath
    }
}

enum AttachmentType: String, Codable {
    case file
    case photo
    case audio
}
