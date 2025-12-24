import Foundation

enum MigratedFilesReader {

    // Local envelope identical in shape to VersionedEnvelope, but WITHOUT Equatable constraints.
    private struct CodableEnvelope<T: Codable>: Codable {
        let schemaVersion: Int
        let updatedAt: Date
        let value: T
    }

    static func readDrafts() throws -> RecoveryResult<[PromiDraft]> {
        let url = try DraftsPaths.draftsFileURL()
        let raw = try RecoveryReader.readOrRecover(from: url)

        func decode(_ data: Data) -> RecoveryResult<[PromiDraft]> {
            do {
                let env = try JSONDecoder().decode(CodableEnvelope<[PromiDraft]>.self, from: data)
                guard env.schemaVersion == 1 else {
                    return .corrupted(reason: "Schema mismatch")
                }
                return .ok(env.value)
            } catch {
                return .corrupted(reason: "Decode failed")
            }
        }

        switch raw {
        case .ok(let data):
            return decode(data)
        case .recoveredFromBackup(let data):
            // Keep the backup provenance
            switch decode(data) {
            case .ok(let v): return .recoveredFromBackup(v)
            case .recoveredFromBackup(let v): return .recoveredFromBackup(v)
            case .corrupted(let reason): return .corrupted(reason: reason)
            }
        case .corrupted(let reason):
            return .corrupted(reason: reason)
        }
    }

    static func readPromiStore() throws -> RecoveryResult<PromiStoreSnapshot> {
        let url = try PromiStorePaths.promiStoreFileURL()
        let raw = try RecoveryReader.readOrRecover(from: url)

        func decode(_ data: Data) -> RecoveryResult<PromiStoreSnapshot> {
            do {
                let env = try JSONDecoder().decode(CodableEnvelope<PromiStoreSnapshot>.self, from: data)
                guard env.schemaVersion == 1 else {
                    return .corrupted(reason: "Schema mismatch")
                }
                return .ok(env.value)
            } catch {
                return .corrupted(reason: "Decode failed")
            }
        }

        switch raw {
        case .ok(let data):
            return decode(data)
        case .recoveredFromBackup(let data):
            switch decode(data) {
            case .ok(let v): return .recoveredFromBackup(v)
            case .recoveredFromBackup(let v): return .recoveredFromBackup(v)
            case .corrupted(let reason): return .corrupted(reason: reason)
            }
        case .corrupted(let reason):
            return .corrupted(reason: reason)
        }
    }
}

