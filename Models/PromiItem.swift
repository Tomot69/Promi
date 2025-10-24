//
//  PromiItem.swift
//  Promi
//
//  Created on 24/10/2025.
//

import Foundation

// MARK: - PromiItem Model
struct PromiItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var dueDate: Date
    var importance: Importance
    var assignee: String?
    var attachments: [Attachment]
    var status: Status
    var intensity: Int // 0–100 (jauge cœur)
    let createdAt: Date
    var completedAt: Date?
    var postponedUntil: Date?
    
    init(
        id: UUID = UUID(),
        title: String,
        dueDate: Date,
        importance: Importance = .normal,
        assignee: String? = nil,
        attachments: [Attachment] = [],
        status: Status = .open,
        intensity: Int = 50,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        postponedUntil: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.importance = importance
        self.assignee = assignee
        self.attachments = attachments
        self.status = status
        self.intensity = intensity
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.postponedUntil = postponedUntil
    }
}

// MARK: - Importance
enum Importance: String, Codable, CaseIterable {
    case low
    case normal
    case urgent
    
    var emoji: String {
        switch self {
        case .low: return "🔥"
        case .normal: return "🔥🔥"
        case .urgent: return "🔥🔥🔥"
        }
    }
}

// MARK: - Status
enum Status: String, Codable {
    case open
    case done
    case postponed
}

// MARK: - Attachment
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
