import Foundation

// MARK: - SyncBackend
//
// `Entity` is declared as a primary associated type (Swift 5.7+ syntax,
// the `<Entity>` after the protocol name). This enables lightweight
// constraint syntax like `any SyncBackend<Nuée>` in store properties
// and init parameters, instead of the more verbose
// `any SyncBackend where Entity == Nuée`.
//
// Stores depend on this protocol, not on a concrete implementation.
// The default `LocalOnlyBackend` is a no-op that keeps the app
// running with zero CloudKit dependency until Apple Dev is paid.

nonisolated protocol SyncBackend<Entity>: Sendable {
    associatedtype Entity: SyncableEntity

    /// Initialize the backend. Returns success once ready to accept
    /// push/fetch calls. May fail (no auth, no network).
    func start() async throws

    /// Push a local entity change to the remote.
    func push(_ envelope: SyncEnvelope<Entity>) async throws

    /// Push a deletion (tombstone) for the given entity id.
    func delete(id: UUID) async throws

    /// Fetch the current remote state of all entities.
    func fetchAll() async throws -> [SyncEnvelope<Entity>]

    /// Subscribe to remote changes.
    func subscribe(onRemoteChange: @escaping (SyncEnvelope<Entity>) -> Void)

    /// Whether this backend is doing remote work, vs being a no-op.
    var isActive: Bool { get }
}
