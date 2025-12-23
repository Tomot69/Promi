import Foundation

enum AppFilePaths {

    static func appSupportDirectory() throws -> URL {
        let base = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return base
    }

    static func fileURL(in directory: URL, filename: String) throws -> URL {
        let trimmed = filename.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            throw PromiError.validation(.empty)
        }
        return directory.appendingPathComponent(trimmed, isDirectory: false)
    }
}
