import Foundation

nonisolated final class LocalOnlyBackend<Entity: SyncableEntity>: SyncBackend, @unchecked Sendable {
    var isActive: Bool { false }

    nonisolated init() {}

    func start() async throws {}
    func push(_ envelope: SyncEnvelope<Entity>) async throws {}
    func delete(id: UUID) async throws {}
    func fetchAll() async throws -> [SyncEnvelope<Entity>] { [] }
    func subscribe(onRemoteChange: @escaping (SyncEnvelope<Entity>) -> Void) {
        _ = onRemoteChange
    }
}
