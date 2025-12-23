import Foundation

enum RecoveryReader {

    static func readOrRecover(from url: URL) throws -> RecoveryResult<Data> {

        // 1) Try main file
        do {
            let data = try Data(contentsOf: url)
            return .ok(data)
        } catch {
            // continue to backup
        }

        // 2) Try backup
        let bakURL = url.appendingPathExtension("bak")
        do {
            let data = try Data(contentsOf: bakURL)
            return .recoveredFromBackup(data)
        } catch {
            return .corrupted(reason: "Main and backup unreadable")
        }
    }
}

