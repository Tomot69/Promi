//
//  NuéeStore.swift
//  Promi
//
//  Phase 1 — Local persistence only. CloudKit sync arrives in Phase 5.
//

import Foundation
import Combine

// MARK: - NuéeStore
//
// The single source of truth for the user's Nuées. Mirrors the structure
// of PromiStore: a simple ObservableObject with a @Published collection,
// CRUD methods that persist to UserDefaults, and computed query helpers.
//
// === CloudKit migration plan (Phase 5) ===
//
// When CloudKit sync arrives, this store gains a hidden sync layer that
// mirrors local writes to a CKDatabase and pulls remote changes via a
// CKSubscription. The public API of this class will NOT change — every
// existing call site keeps working without modification. The persistence
// will simply become bidirectional.
//
// Hooks for the migration are pre-marked in the code with `// CK-HOOK:`
// comments at every persistence boundary. Phase 5 will replace these
// boundaries with CKModifyRecordsOperation calls.
//
// === Phase 1 scope ===
//
// - Create a Nuée
// - Update a Nuée (rename, add/remove members, change kind, change theme,
//   set/unset expiresAt, change moodHint)
// - Delete a Nuée
// - List the user's Nuées (active vs expired)
// - Query helpers for the home Voronoï rendering (Phase 3) and the sort
//   (Phase 4)

final class NuéeStore: ObservableObject {
    @Published var nuées: [Nuée] = []

    private let userDefaults = UserDefaults.standard
    private let nuéesKey = "promiNuées.v1"

    init() {
        loadNuées()
    }

    // MARK: - CRUD

    func create(_ nuée: Nuée) {
        nuées.append(nuée)
        persistNuées()
        objectWillChange.send()
        // CK-HOOK: queue CKRecord create for this Nuée
    }

    func update(_ nuée: Nuée) {
        guard let index = nuées.firstIndex(where: { $0.id == nuée.id }) else { return }
        nuées[index] = nuée
        persistNuées()
        objectWillChange.send()
        // CK-HOOK: queue CKRecord modify for this Nuée
    }

    func delete(_ nuée: Nuée) {
        nuées.removeAll { $0.id == nuée.id }
        persistNuées()
        objectWillChange.send()
        // CK-HOOK: queue CKRecord delete for this Nuée + cascade clear
        //          of nuéeId on all PromiItems that referenced it
    }

    // MARK: - Member management

    /// Add a member to a Nuée. The member is created with hasAccepted=true
    /// for now — Phase 6 (invitation flow) will introduce hasAccepted=false
    /// for pending invitations.
    func addMember(
        _ member: NuéeMember,
        to nuéeId: UUID
    ) {
        guard let index = nuées.firstIndex(where: { $0.id == nuéeId }) else { return }
        guard !nuées[index].includes(userId: member.id) else { return }
        nuées[index].members.append(member)
        persistNuées()
        objectWillChange.send()
        // CK-HOOK: queue CKShare update for this Nuée's participant list
    }

    func removeMember(
        userId: String,
        from nuéeId: UUID
    ) {
        guard let index = nuées.firstIndex(where: { $0.id == nuéeId }) else { return }
        nuées[index].members.removeAll { $0.id == userId }
        persistNuées()
        objectWillChange.send()
        // CK-HOOK: queue CKShare update for this Nuée's participant list
    }

    // MARK: - Query helpers

    /// All Nuées the given user is a member of (accepted or pending).
    func nuées(for userId: String) -> [Nuée] {
        nuées.filter { $0.includes(userId: userId) }
    }

    /// All Nuées the given user has actually joined (not just been invited).
    func joinedNuées(for userId: String) -> [Nuée] {
        nuées.filter { $0.hasJoined(userId: userId) }
    }

    /// All currently active (non-expired) Nuées for the given user.
    func activeNuées(for userId: String) -> [Nuée] {
        joinedNuées(for: userId).filter { !$0.isExpired }
    }

    /// All expired Nuées for the given user (read-only archive).
    func expiredNuées(for userId: String) -> [Nuée] {
        joinedNuées(for: userId).filter(\.isExpired)
    }

    /// Find a single Nuée by id.
    func nuée(with id: UUID) -> Nuée? {
        nuées.first { $0.id == id }
    }

    /// Lookup helper for Phase 3 (Voronoï rendering): given a PromiItem's
    /// nuéeId, return the matching Nuée or nil if it's a personal Promi
    /// or the Nuée has been deleted.
    func nuée(forPromiItemNuéeId nuéeId: UUID?) -> Nuée? {
        guard let nuéeId else { return nil }
        return nuée(with: nuéeId)
    }

    // MARK: - Persistence

    private func loadNuées() {
        guard
            let data = userDefaults.data(forKey: nuéesKey),
            let decoded = try? JSONDecoder().decode([Nuée].self, from: data)
        else {
            return
        }
        nuées = decoded
    }

    private func persistNuées() {
        // CK-HOOK: this is the local-mirror write. In Phase 5, this same
        // method also queues a CK sync operation in the background. The
        // local write happens first to keep the UI snappy.
        guard let encoded = try? JSONEncoder().encode(nuées) else { return }
        userDefaults.set(encoded, forKey: nuéesKey)
    }
}
