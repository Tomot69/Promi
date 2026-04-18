import Foundation
import Combine

// MARK: - NuéeStore (R5 Phase C)
//
// Now backed by an injectable SyncBackend. The default backend is
// LocalOnlyBackend<Nuée> — a no-op that satisfies the protocol but
// does nothing remote, keeping the app behavior IDENTICAL to before
// R5. When CloudKit is enabled (Phase D, post Apple Dev paid), the
// init can be called with CloudKitNuéeBackend instead — zero changes
// to the rest of the app.
//
// Each mutation increments `version` and stamps `lastModified`, then
// fires a fire-and-forget `backend.push()` via Task.detached. The
// store skips the push entirely when `backend.isActive == false` to
// avoid useless work in the LocalOnly path.

@MainActor
final class NuéeStore: ObservableObject {
    @Published var nuées: [Nuée] = []

    private let userDefaults = UserDefaults.standard
    private let nuéesKey = "promiNuées.v1"
    private let backend: any SyncBackend<Nuée>
    private let deviceId: String

    init(backend: (any SyncBackend<Nuée>)? = nil) {
        self.backend = backend ?? LocalOnlyBackend<Nuée>()
        self.deviceId = Self.resolveDeviceId()
        loadNuées()
    }

    private static func resolveDeviceId() -> String {
        if let existing = UserDefaults.standard.string(forKey: "promi.deviceId") {
            return existing
        }
        let new = UUID().uuidString
        UserDefaults.standard.set(new, forKey: "promi.deviceId")
        return new
    }

    // MARK: - CRUD

    func create(_ nuée: Nuée) {
        var stamped = nuée
        stamped.version = max(1, nuée.version)
        stamped.lastModified = Date()
        nuées.append(stamped)
        persistNuées()
        objectWillChange.send()
        pushIfActive(stamped, isTombstone: false)
    }

    func update(_ nuée: Nuée) {
        guard let index = nuées.firstIndex(where: { $0.id == nuée.id }) else { return }
        var stamped = nuée
        stamped.version = nuées[index].version + 1
        stamped.lastModified = Date()
        nuées[index] = stamped
        persistNuées()
        objectWillChange.send()
        pushIfActive(stamped, isTombstone: false)
    }

    func delete(_ nuée: Nuée) {
        let snapshot = nuées.first { $0.id == nuée.id }
        nuées.removeAll { $0.id == nuée.id }
        persistNuées()
        objectWillChange.send()
        if let snapshot {
            pushIfActive(snapshot, isTombstone: true)
        }
    }

    // MARK: - Member management

    func addMember(_ member: NuéeMember, to nuéeId: UUID) {
        guard let index = nuées.firstIndex(where: { $0.id == nuéeId }) else { return }
        guard !nuées[index].includes(userId: member.id) else { return }
        nuées[index].members.append(member)
        nuées[index].version += 1
        nuées[index].lastModified = Date()
        let updated = nuées[index]
        persistNuées()
        objectWillChange.send()
        pushIfActive(updated, isTombstone: false)
    }

    func removeMember(userId: String, from nuéeId: UUID) {
        guard let index = nuées.firstIndex(where: { $0.id == nuéeId }) else { return }
        nuées[index].members.removeAll { $0.id == userId }
        nuées[index].version += 1
        nuées[index].lastModified = Date()
        let updated = nuées[index]
        persistNuées()
        objectWillChange.send()
        pushIfActive(updated, isTombstone: false)
    }

    // MARK: - Query helpers

    func nuées(for userId: String) -> [Nuée] {
        nuées.filter { $0.includes(userId: userId) }
    }

    func joinedNuées(for userId: String) -> [Nuée] {
        nuées.filter { $0.hasJoined(userId: userId) }
    }

    func activeNuées(for userId: String) -> [Nuée] {
        joinedNuées(for: userId).filter { !$0.isExpired }
    }

    func expiredNuées(for userId: String) -> [Nuée] {
        joinedNuées(for: userId).filter(\.isExpired)
    }

    func nuée(with id: UUID) -> Nuée? {
        nuées.first { $0.id == id }
    }

    func nuée(forPromiItemNuéeId nuéeId: UUID?) -> Nuée? {
        guard let nuéeId else { return nil }
        return nuée(with: nuéeId)
    }

    /// Sous-Nuées thématiques rattachées à une Nuée intime parente.
    /// Triées par date de création descendante (plus récentes en haut).
    func childNuées(of parentId: UUID) -> [Nuée] {
        nuées
            .filter { $0.parentNuéeId == parentId }
            .sorted { $0.createdAt > $1.createdAt }
    }

    /// Nuées top-level uniquement (pas les sous-thématiques). Utilisé
    /// par MesNuéesView pour ne montrer que les Nuées de premier niveau.
    func topLevelNuées(for userId: String) -> [Nuée] {
        nuées.filter { $0.isTopLevel && $0.includes(userId: userId) }
    }

    func topLevelActiveNuées(for userId: String) -> [Nuée] {
        topLevelNuées(for: userId).filter { !$0.isExpired }
    }

    // MARK: - Persistence

    private func loadNuées() {
        guard
            let data = userDefaults.data(forKey: nuéesKey),
            let decoded = try? JSONDecoder().decode([Nuée].self, from: data)
        else { return }
        nuées = decoded
    }

    private func persistNuées() {
        guard let encoded = try? JSONEncoder().encode(nuées) else { return }
        userDefaults.set(encoded, forKey: nuéesKey)
    }

    // MARK: - Sync push (fire-and-forget)
    //
    // Skipped entirely when the backend is inactive (LocalOnly). When
    // active (CloudKit), runs in a detached task so the UI never blocks
    // on network I/O. Failures are logged but never bubble up — the
    // local write is the source of truth, sync is best-effort.

    private func pushIfActive(_ nuée: Nuée, isTombstone: Bool) {
        guard backend.isActive else { return }
        let envelope = SyncEnvelope(
            entity: nuée,
            originDeviceId: deviceId,
            isTombstone: isTombstone
        )
        let id = nuée.id
        let backend = self.backend
        Task.detached {
            do {
                if isTombstone {
                    try await backend.delete(id: id)
                } else {
                    try await backend.push(envelope)
                }
            } catch {
                if FeatureFlags.syncDiagnosticsEnabled {
                    print("[NuéeStore] sync push failed: \(error.localizedDescription)")
                }
            }
        }
    }
}
