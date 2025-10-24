//
//  PromiStore.swift
//  Promi
//
//  Created on 24/10/2025.
//

import Foundation
import Combine

// MARK: - Promi Store
class PromiStore: ObservableObject {
    @Published var promis: [PromiItem] = []
    @Published var bravos: [Bravo] = []
    @Published var comments: [Comment] = []
    
    private let fileName = "promis.json"
    private let bravosFileName = "bravos.json"
    private let commentsFileName = "comments.json"
    
    init() {
        loadPromis()
        loadBravos()
        loadComments()
    }
    
    // MARK: - Promi CRUD
    func addPromi(_ promi: PromiItem) {
        promis.append(promi)
        savePromis()
        Haptics.shared.success()
    }
    
    func updatePromi(_ promi: PromiItem) {
        if let index = promis.firstIndex(where: { $0.id == promi.id }) {
            promis[index] = promi
            savePromis()
        }
    }
    
    func deletePromi(_ promi: PromiItem) {
        promis.removeAll { $0.id == promi.id }
        bravos.removeAll { $0.promiId == promi.id }
        comments.removeAll { $0.promiId == promi.id }
        savePromis()
        saveBravos()
        saveComments()
    }
    
    func markAsDone(_ promi: PromiItem) {
        var updated = promi
        updated.status = .done
        updated.completedAt = Date()
        updatePromi(updated)
        Haptics.shared.success()
    }
    
    func markAsOpen(_ promi: PromiItem) {
        var updated = promi
        updated.status = .open
        updated.completedAt = nil
        updatePromi(updated)
        Haptics.shared.lightTap()
    }
    
    // MARK: - Bravo CRUD
    func toggleBravo(promiId: UUID, userId: String) {
        if let existing = bravos.first(where: { $0.promiId == promiId && $0.userId == userId }) {
            bravos.removeAll { $0.id == existing.id }
        } else {
            let newBravo = Bravo(promiId: promiId, userId: userId)
            bravos.append(newBravo)
        }
        saveBravos()
        Haptics.shared.tinyPop()
    }
    
    func getBravosCount(for promiId: UUID) -> Int {
        bravos.filter { $0.promiId == promiId }.count
    }
    
    func hasBravo(promiId: UUID, userId: String) -> Bool {
        bravos.contains { $0.promiId == promiId && $0.userId == userId }
    }
    
    // MARK: - Comment CRUD
    func addComment(promiId: UUID, authorId: String, text: String) {
        let comment = Comment(promiId: promiId, authorId: authorId, text: text)
        comments.append(comment)
        saveComments()
        Haptics.shared.lightTap()
    }
    
    func getComments(for promiId: UUID) -> [Comment] {
        comments.filter { $0.promiId == promiId }.sorted { $0.createdAt < $1.createdAt }
    }
    
    func getCommentsCount(for promiId: UUID) -> Int {
        comments.filter { $0.promiId == promiId }.count
    }
    
    // MARK: - Persistence
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func savePromis() {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        if let data = try? JSONEncoder().encode(promis) {
            try? data.write(to: url)
        }
    }
    
    private func loadPromis() {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([PromiItem].self, from: data) {
            promis = decoded
        }
    }
    
    private func saveBravos() {
        let url = getDocumentsDirectory().appendingPathComponent(bravosFileName)
        if let data = try? JSONEncoder().encode(bravos) {
            try? data.write(to: url)
        }
    }
    
    private func loadBravos() {
        let url = getDocumentsDirectory().appendingPathComponent(bravosFileName)
        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([Bravo].self, from: data) {
            bravos = decoded
        }
    }
    
    private func saveComments() {
        let url = getDocumentsDirectory().appendingPathComponent(commentsFileName)
        if let data = try? JSONEncoder().encode(comments) {
            try? data.write(to: url)
        }
    }
    
    private func loadComments() {
        let url = getDocumentsDirectory().appendingPathComponent(commentsFileName)
        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([Comment].self, from: data) {
            comments = decoded
        }
    }
}
