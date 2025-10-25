//
//  PromiStore.swift
//  Promi
//
//  Created on 25/10/2025.
//

import Foundation
import Combine

// MARK: - Promi Store
class PromiStore: ObservableObject {
    @Published var promis: [PromiItem] = []
    @Published var bravos: [Bravo] = []
    @Published var comments: [Comment] = []
    
    private let userDefaults = UserDefaults.standard
    private let promisKey = "promiItems"
    private let bravosKey = "promiBravos"
    private let commentsKey = "promiComments"
    
    init() {
        loadPromis()
        loadBravos()
        loadComments()
    }
    
    func addPromi(_ promi: PromiItem) {
        promis.append(promi)
        persistPromis()
        objectWillChange.send()
    }
    
    func updatePromi(_ promi: PromiItem) {
        if let index = promis.firstIndex(where: { $0.id == promi.id }) {
            promis[index] = promi
            persistPromis()
            objectWillChange.send()
        }
    }
    
    func deletePromi(_ promi: PromiItem) {
        promis.removeAll { $0.id == promi.id }
        bravos.removeAll { $0.promiId == promi.id }
        comments.removeAll { $0.promiId == promi.id }
        persistPromis()
        persistBravos()
        persistComments()
        objectWillChange.send()
    }
    
    func markAsDone(_ promi: PromiItem) {
        if let index = promis.firstIndex(where: { $0.id == promi.id }) {
            promis[index].status = .done
            promis[index].completedAt = Date()
            persistPromis()
            objectWillChange.send()
        }
    }
    
    func markAsOpen(_ promi: PromiItem) {
        if let index = promis.firstIndex(where: { $0.id == promi.id }) {
            promis[index].status = .open
            promis[index].completedAt = nil
            persistPromis()
            objectWillChange.send()
        }
    }
    
    // MARK: - Bravos
    func addBravo(_ bravo: Bravo) {
        bravos.append(bravo)
        persistBravos()
        objectWillChange.send()
    }
    
    func getBravosCount(for promiId: UUID) -> Int {
        return bravos.filter { $0.promiId == promiId }.count
    }
    
    func hasBravo(promiId: UUID, userId: String) -> Bool {
        return bravos.contains { $0.promiId == promiId && $0.userId == userId }
    }
    
    // MARK: - Comments
    func addComment(_ comment: Comment) {
        comments.append(comment)
        persistComments()
        objectWillChange.send()
    }
    
    func getCommentsCount(for promiId: UUID) -> Int {
        return comments.filter { $0.promiId == promiId }.count
    }
    
    func getComments(for promiId: UUID) -> [Comment] {
        return comments.filter { $0.promiId == promiId }
    }
    
    // MARK: - Persistence
    private func loadPromis() {
        guard let data = userDefaults.data(forKey: promisKey),
              let decoded = try? JSONDecoder().decode([PromiItem].self, from: data) else {
            return
        }
        promis = decoded
    }
    
    private func persistPromis() {
        if let encoded = try? JSONEncoder().encode(promis) {
            userDefaults.set(encoded, forKey: promisKey)
        }
    }
    
    private func loadBravos() {
        guard let data = userDefaults.data(forKey: bravosKey),
              let decoded = try? JSONDecoder().decode([Bravo].self, from: data) else {
            return
        }
        bravos = decoded
    }
    
    private func persistBravos() {
        if let encoded = try? JSONEncoder().encode(bravos) {
            userDefaults.set(encoded, forKey: bravosKey)
        }
    }
    
    private func loadComments() {
        guard let data = userDefaults.data(forKey: commentsKey),
              let decoded = try? JSONDecoder().decode([Comment].self, from: data) else {
            return
        }
        comments = decoded
    }
    
    private func persistComments() {
        if let encoded = try? JSONEncoder().encode(comments) {
            userDefaults.set(encoded, forKey: commentsKey)
        }
    }
}
