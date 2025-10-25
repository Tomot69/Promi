//
//  Reaction.swift
//  Promi
//
//  Created on 25/10/2025.
//

import Foundation

// MARK: - Bravo (Like)
struct Bravo: Identifiable, Codable {
    let id: UUID
    let promiId: UUID
    let userId: String
    let createdAt: Date
    
    init(promiId: UUID, userId: String) {
        self.id = UUID()
        self.promiId = promiId
        self.userId = userId
        self.createdAt = Date()
    }
}

// MARK: - Comment
struct Comment: Identifiable, Codable {
    let id: UUID
    let promiId: UUID
    let userId: String
    let text: String
    let createdAt: Date
    
    init(promiId: UUID, userId: String, text: String) {
        self.id = UUID()
        self.promiId = promiId
        self.userId = userId
        self.text = text
        self.createdAt = Date()
    }
}
