//
//  Reaction.swift
//  Promi
//
//  Created on 24/10/2025.
//

import Foundation

// MARK: - Bravo Model
struct Bravo: Identifiable, Codable, Equatable {
    let id: UUID
    let promiId: UUID
    let userId: String // localUserId
    let createdAt: Date
    
    init(id: UUID = UUID(), promiId: UUID, userId: String, createdAt: Date = Date()) {
        self.id = id
        self.promiId = promiId
        self.userId = userId
        self.createdAt = createdAt
    }
}

// MARK: - Comment Model
struct Comment: Identifiable, Codable, Equatable {
    let id: UUID
    let promiId: UUID
    let authorId: String
    var text: String // max 240
    let createdAt: Date
    
    init(id: UUID = UUID(), promiId: UUID, authorId: String, text: String, createdAt: Date = Date()) {
        self.id = id
        self.promiId = promiId
        self.authorId = authorId
        self.text = text
        self.createdAt = createdAt
    }
}
