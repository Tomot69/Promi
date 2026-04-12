import Foundation
import Combine

// MARK: - Draft Store
//
// Unified store for both Promi drafts and Nuée drafts. Each type has
// its own UserDefaults key and CRUD methods. The store exposes two
// published arrays so views can observe each type independently.
//
// Pattern: same persistence approach as PromiStore (JSON encode →
// UserDefaults). Separate keys ensure backward compatibility — old
// users who upgrade keep their Promi drafts intact.

class DraftStore: ObservableObject {
    @Published var drafts: [PromiDraft] = []
    @Published var nuéeDrafts: [NuéeDraft] = []

    private let userDefaults = UserDefaults.standard
    private let draftsKey = "promiDrafts"
    private let nuéeDraftsKey = "promiNuéeDrafts.v1"

    init() {
        loadDrafts()
        loadNuéeDrafts()
    }

    // MARK: - Promi Drafts

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

    // MARK: - Nuée Drafts

    func saveNuéeDraft(_ draft: NuéeDraft) {
        if let index = nuéeDrafts.firstIndex(where: { $0.id == draft.id }) {
            nuéeDrafts[index] = draft
        } else {
            nuéeDrafts.append(draft)
        }
        persistNuéeDrafts()
        objectWillChange.send()
    }

    func deleteNuéeDraft(_ draft: NuéeDraft) {
        nuéeDrafts.removeAll { $0.id == draft.id }
        persistNuéeDrafts()
        objectWillChange.send()
    }

    func deleteAllNuéeDrafts() {
        nuéeDrafts.removeAll()
        persistNuéeDrafts()
        objectWillChange.send()
    }

    // MARK: - Convenience

    /// Total draft count (Promi + Nuée) for badge display in the dock.
    var totalDraftCount: Int {
        drafts.count + nuéeDrafts.count
    }

    // MARK: - Persistence (Promi)

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

    // MARK: - Persistence (Nuée)

    private func loadNuéeDrafts() {
        guard let data = userDefaults.data(forKey: nuéeDraftsKey),
              let decoded = try? JSONDecoder().decode([NuéeDraft].self, from: data) else {
            return
        }
        nuéeDrafts = decoded
    }

    private func persistNuéeDrafts() {
        if let encoded = try? JSONEncoder().encode(nuéeDrafts) {
            userDefaults.set(encoded, forKey: nuéeDraftsKey)
        }
    }
}
