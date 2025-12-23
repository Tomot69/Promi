import Foundation

enum DataRoot {

    static func baseDirectory() throws -> URL {
        let dir = try AppFilePaths.appSupportDirectory()
            .appendingPathComponent("promi", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static func storeFileURL() throws -> URL {
        let dir = try baseDirectory()
        return try AppFilePaths.fileURL(in: dir, filename: "store.json")
    }

    static func auditFileURL() throws -> URL {
        let dir = try baseDirectory()
        return try AppFilePaths.fileURL(in: dir, filename: "audit.jsonl")
    }
}
