import Foundation

enum DraftsMigrator {

    // OFF by default: migration must be explicitly enabled by caller.
    static var isEnabled: Bool = false

    // Strict-only: if legacy read is corrupted, do not write anything.
    // Writes a versioned envelope whose value is the legacy JSON bytes (Data).
    static func migrate(from defaults: UserDefaults, to url: URL) throws -> RecoveryResult<Void> {
        guard isEnabled else {
            return .corrupted(reason: "Migration disabled")
        }

        let strict = LegacyDraftsReader.readStrict(from: defaults)

        switch strict {
        case .ok(let drafts):
            // Encode back to legacy JSON bytes to avoid inventing any schema
            let legacyBytes: Data
            do {
                legacyBytes = try JSONEncoder().encode(drafts)
            } catch {
                return .corrupted(reason: "Encode failed: \(LegacyUserDefaultsKeys.draftsKey)")
            }

            if legacyBytes.isEmpty {
                return .corrupted(reason: "Empty encoded drafts")
            }

            let env = VersionedEnvelope(schemaVersion: 1, updatedAt: Date(), value: legacyBytes)
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
        let url = try DraftsPaths.draftsFileURL()
        return try migrate(from: defaults, to: url)
    }
}

