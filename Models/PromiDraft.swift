//
//  PromiDraft.swift
//  Promi
//
//  Created on 25/10/2025.
//

import Foundation

// MARK: - Promi Draft Model
struct PromiDraft: Identifiable, Codable {
    let id: UUID
    var title: String
    var dueDate: Date
    var assignee: String?
    var intensity: Int
    var audioURL: URL?
    var attachments: [URL]
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        title: String = "",
        dueDate: Date = Date(),
        assignee: String? = nil,
        intensity: Int = 50,
        audioURL: URL? = nil,
        attachments: [URL] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.assignee = assignee
        self.intensity = intensity
        self.audioURL = audioURL
        self.attachments = attachments
        self.createdAt = createdAt
    }
}
