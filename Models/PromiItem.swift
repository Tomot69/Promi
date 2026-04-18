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

    /// Identifiants des PromiContact destinataires de ce Promi (multi-
    /// destinataires possibles : un Promi peut s'adresser à plusieurs
    /// personnes nommément). Sert de remplacement structuré au champ
    /// `assignee` (string libre, conservé pour la rétrocompat).
    /// Backward-compatible : JSON sans le champ → tableau vide. Les
    /// IDs sont les `id` locaux du ContactsStore (UUID strings) ; ils
    /// resteront valides quand chaque contact gagnera son appleUserId.
    var recipientContactIds: [String]

    /// ID local (PromiContact.id) de l'utilisateur qui a envoyé ce Promi.
    /// `nil` = Promi créé par l'utilisateur courant pour lui-même (cas
    /// actuel par défaut, pré-CloudKit). Quand CloudKit sera actif,
    /// les Promi reçus via sync auront ce champ rempli — c'est sur cette
    /// valeur que reposent le blocage et le signalement.
    var senderContactId: String?

    /// ID Apple stable de l'expéditeur (fourni par Sign in with Apple).
    /// `nil` tant que la sync sociale n'est pas active. Dès que CloudKit
    /// est branché, ce champ est rempli automatiquement à la réception.
    /// Sert de pont fiable pour reconcilier les contacts locaux avec
    /// les vrais utilisateurs Apple.
    var senderAppleUserId: String?

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
        nuéeId: UUID? = nil,
        recipientContactIds: [String] = [],
        senderContactId: String? = nil,
        senderAppleUserId: String? = nil
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
        self.recipientContactIds = recipientContactIds
        self.senderContactId = senderContactId
        self.senderAppleUserId = senderAppleUserId
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
        case recipientContactIds
        case senderContactId
        case senderAppleUserId
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
        // Backward-compatible: missing in old JSON → []. Personal Promi
        // ou Promi pré-Phase 6 sans destinataires structurés.
        recipientContactIds = try container.decodeIfPresent([String].self, forKey: .recipientContactIds) ?? []
        // Backward-compatible: missing → nil. Promi pré-CloudKit ou
        // créé par l'utilisateur lui-même (cas par défaut).
        senderContactId = try container.decodeIfPresent(String.self, forKey: .senderContactId)
        senderAppleUserId = try container.decodeIfPresent(String.self, forKey: .senderAppleUserId)
    }

    /// True si ce Promi a été reçu d'un autre utilisateur (sync CloudKit
    /// future). Pour les Promi créés par l'utilisateur courant pour
    /// lui-même, retourne false. Sert à déterminer si les actions
    /// "bloquer / signaler l'expéditeur" sont disponibles.
    var isReceivedFromOther: Bool {
        senderContactId != nil || senderAppleUserId != nil
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
