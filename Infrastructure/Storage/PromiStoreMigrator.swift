import Foundation

enum PromiStoreMigrator {

    // OFF by default: migration must be explicitly enabled by caller.
    static var isEnabled: Bool = false

    // Strict-only: if legacy read is corrupted OR violates invariants, do not write anything.
    static func migrate(from defaults: UserDefaults, to url: URL) throws -> RecoveryResult<Void> {
        guard isEnabled else { return .corrupted(reason: "Migration disabled") }

        let strict = LegacyPromiStoreReader.readAllStrict(from: defaults)

        switch strict {
        case .ok(let tuple):
            // Enforce invariant: unique bravo per (promiId, userId).
            if violatesUniqueBravo(bravos: tuple.bravos) {
                return .corrupted(reason: "Invariant failed: duplicate bravo")
            }

            let snap = PromiStoreSnapshot.v1(promis: tuple.promis, bravos: tuple.bravos, comments: tuple.comments)
            let env = VersionedEnvelope(schemaVersion: 1, updatedAt: Date(), value: snap)
            try JSONStore.write(envelope: env, to: url)
            return .ok(())

        case .recoveredFromBackup:
            // Not applicable for UserDefaults legacy reader
            return .corrupted(reason: "Unexpected state")

        case .corrupted(let reason):
            return .corrupted(reason: reason)
        }
    }

    static func migrateToDefaultLocation(from defaults: UserDefaults) throws -> RecoveryResult<Void> {
        let url = try PromiStorePaths.promiStoreFileURL()
        return try migrate(from: defaults, to: url)
    }

    private static func violatesUniqueBravo(bravos: [Bravo]) -> Bool {
        var seen = Set<String>()
        for b in bravos {
            let key = "\(b.promiId.uuidString)|\(b.userId)"
            if seen.contains(key) { return true }
            seen.insert(key)
        }
        return false
    }
}
