import Foundation

enum RawStoreDataReader {

    // Store format is NON DEFINI at this stage: read-only bytes only.
    static func read(from url: URL) throws -> RecoveryResult<Data> {
        let result: RecoveryResult<Data> = try RecoveryReader.readOrRecover(from: url)

        switch result {
        case .ok(let data):
            return validateNonEmpty(data: data, origin: "main")

        case .recoveredFromBackup(let data):
            return validateNonEmpty(data: data, origin: "backup")

        case .corrupted(let reason):
            return .corrupted(reason: reason)
        }
    }

    private static func validateNonEmpty(data: Data, origin: String) -> RecoveryResult<Data> {
        if data.isEmpty {
            return .corrupted(reason: "Empty data (\(origin))")
        }
        return origin == "main" ? .ok(data) : .recoveredFromBackup(data)
    }
}
