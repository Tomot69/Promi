import Foundation

// MARK: - CloudKitNuéeBackend (R5 Phase C — STUB)
//
// Skeleton implementation of SyncBackend backed by CloudKit. INTENTIONALLY
// does NOT import CloudKit yet — that import requires the iCloud
// capability + entitlements file + a paid Apple Developer account, none
// of which exist yet. The day those three things land, this stub gets
// fleshed out with CKDatabase / CKRecord / CKQuerySubscription calls.
//
// For now this class:
//   - Conforms to SyncBackend so it can be passed to NuéeStore.init
//   - Reports `isActive = FeatureFlags.cloudKitSyncEnabled` (so OFF)
//   - All methods are no-ops that throw a "not yet implemented" error
//
// Activation checklist (Phase D):
//   1. Add `import CloudKit`
//   2. Add `let container = CKContainer(identifier: "iCloud.com.promi.app")`
//   3. Implement push() with CKModifyRecordsOperation
//   4. Implement fetchAll() with CKQueryOperation
//   5. Implement subscribe() with CKQuerySubscription + remote notifications
//   6. Set FeatureFlags.cloudKitSyncEnabled = true
//   7. Update PromiApp to inject CloudKitNuéeBackend() instead of nil
//
// Until then, NuéeStore continues to use LocalOnlyBackend by default.

nonisolated final class CloudKitNuéeBackend: SyncBackend, @unchecked Sendable {
    typealias Entity = Nuée

    var isActive: Bool { FeatureFlags.cloudKitSyncEnabled }

    nonisolated init() {}

    func start() async throws {
        guard isActive else { return }
        throw CloudKitNuéeBackendError.notYetImplemented(
            "CloudKit sync requires Apple Dev account + iCloud entitlement"
        )
    }

    func push(_ envelope: SyncEnvelope<Nuée>) async throws {
        guard isActive else { return }
        throw CloudKitNuéeBackendError.notYetImplemented("push")
    }

    func delete(id: UUID) async throws {
        guard isActive else { return }
        throw CloudKitNuéeBackendError.notYetImplemented("delete")
    }

    func fetchAll() async throws -> [SyncEnvelope<Nuée>] {
        guard isActive else { return [] }
        throw CloudKitNuéeBackendError.notYetImplemented("fetchAll")
    }

    func subscribe(onRemoteChange: @escaping (SyncEnvelope<Nuée>) -> Void) {
        // No-op in stub. Phase D will register a CKQuerySubscription.
        _ = onRemoteChange
    }
}

nonisolated enum CloudKitNuéeBackendError: Error, Sendable {
    case notYetImplemented(String)
}
