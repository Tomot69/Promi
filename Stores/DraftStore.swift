//
//  DraftStore.swift
//  Promi
//
//  Created on 25/10/2025.
//

import Foundation
import Combine

// MARK: - Draft Store
class DraftStore: ObservableObject {
    @Published var drafts: [PromiDraft] = []
    
    private let userDefaults = UserDefaults.standard
    private let draftsKey = "promiDrafts"
    
    init() {
        loadDrafts()
    }
    
    func saveDraft(_ draft: PromiDraft) {
        if let index = drafts.firstIndex(where: { $0.id == draft.id }) {
            drafts[index] = draft
        } else {
            drafts.append(draft)
        }
        persistDrafts()
        objectWillChange.send()
    }
    
    func deleteDraft(_ draft: PromiDraft) {
        drafts.removeAll { $0.id == draft.id }
        persistDrafts()
        objectWillChange.send()
    }
    
    func deleteAllDrafts() {
        drafts.removeAll()
        persistDrafts()
        objectWillChange.send()
    }
    
    private func loadDrafts() {
        guard let data = userDefaults.data(forKey: draftsKey),
              let decoded = try? JSONDecoder().decode([PromiDraft].self, from: data) else {
            return
        }
        drafts = decoded
    }
    
    private func persistDrafts() {
        if let encoded = try? JSONEncoder().encode(drafts) {
            userDefaults.set(encoded, forKey: draftsKey)
        }
    }
}
