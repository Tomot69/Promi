import Foundation

enum JSONStore {

    // Read path is via RecoveryReader (file -> .bak -> corrupted).
    static func read<T: Codable & Equatable>(
        from url: URL,
        expectedSchemaVersion: Int
    ) throws -> RecoveryResult<VersionedEnvelope<T>> {

        let recovered: RecoveryResult<Data> = try RawStoreDataReader.read(from: url)

        switch recovered {
        case .ok(let data):
            return decodeStrict(data: data, expectedSchemaVersion: expectedSchemaVersion, origin: "main")

        case .recoveredFromBackup(let data):
            return decodeStrict(data: data, expectedSchemaVersion: expectedSchemaVersion, origin: "backup")

        case .corrupted(let reason):
            return .corrupted(reason: reason)
        }
    }

    // Write path is atomic + validated + .bak rotation (already handled by AtomicFileWriter).
    static func write<T: Codable & Equatable>(
        envelope: VersionedEnvelope<T>,
        to url: URL
    ) throws {

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let data: Data
        do {
            data = try encoder.encode(envelope)
        } catch {
            throw PromiError.persistence(.encodeFailed)
        }

        if data.isEmpty {
            throw PromiError.persistence(.encodeFailed)
        }

        try AtomicFileWriter.writeAtomic(data: data, to: url)
    }

    private static func decodeStrict<T: Codable & Equatable>(
        data: Data,
        expectedSchemaVersion: Int,
        origin: String
    ) -> RecoveryResult<VersionedEnvelope<T>> {

        if data.isEmpty {
            return .corrupted(reason: "Empty data (\(origin))")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let env = try decoder.decode(VersionedEnvelope<T>.self, from: data)
            if env.schemaVersion != expectedSchemaVersion {
                return .corrupted(reason: "Unsupported schemaVersion=\(env.schemaVersion) (\(origin))")
            }
            return origin == "main" ? .ok(env) : .recoveredFromBackup(env)
        } catch {
            return .corrupted(reason: "Decode failed (\(origin))")
        }
    }
}
