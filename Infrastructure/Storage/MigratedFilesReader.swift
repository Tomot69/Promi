import Foundation

enum MigratedFilesReader {

    // Local envelope identical in shape to VersionedEnvelope, but WITHOUT Equatable constraints.
    private struct CodableEnvelope<T: Codable>: Codable {
        let schemaVersion: Int
        let updatedAt: Date
        let value: T
    }

    // We MUST use a deterministic date decoding strategy, otherwise Date decoding will fail.
    // Here we support:
    // - ISO8601 strings (recommended)
    // - Numeric seconds since 1970 (common legacy)
    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .custom { dec in
            let container = try dec.singleValueContainer()

            // 1) ISO8601 string
            if let s = try? container.decode(String.self) {
                let iso = ISO8601DateFormatter()
                iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let d = iso.date(from: s) { return d }

                // fallback without fractional seconds
                let iso2 = ISO8601DateFormatter()
                iso2.formatOptions = [.withInternetDateTime]
                if let d = iso2.date(from: s) { return d }

                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid ISO8601 date string: \(s)"
                )
            }

            // 2) Numeric timestamp (seconds since 1970)
            if let t = try? container.decode(Double.self) {
                return Date(timeIntervalSince1970: t)
            }
            if let i = try? container.decode(Int.self) {
                return Date(timeIntervalSince1970: TimeInterval(i))
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported date format"
            )
        }

        return decoder
    }

    static func readDrafts() throws -> RecoveryResult<[PromiDraft]> {
        let url = try DraftsPaths.draftsFileURL()
        let raw = try RecoveryReader.readOrRecover(from: url)

        func decode(_ data: Data) -> RecoveryResult<[PromiDraft]> {
            do {
                let env = try makeDecoder().decode(CodableEnvelope<[PromiDraft]>.self, from: data)
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

    static func readPromiStore() throws -> RecoveryResult<PromiStoreSnapshot> {
        let url = try PromiStorePaths.promiStoreFileURL()
        let raw = try RecoveryReader.readOrRecover(from: url)

        func decode(_ data: Data) -> RecoveryResult<PromiStoreSnapshot> {
            do {
                let env = try makeDecoder().decode(CodableEnvelope<PromiStoreSnapshot>.self, from: data)
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

