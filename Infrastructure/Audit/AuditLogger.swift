import Foundation

enum AuditLogger {

    static func append(event: AuditEvent, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let line: Data
        do {
            line = try encoder.encode(event) + Data([0x0A]) // newline
        } catch {
            throw PromiError.persistence(.encodeFailed)
        }

        // Ensure dir exists
        let dir = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try AtomicFileWriter.writeAtomic(data: line, to: url)
            } catch {
                throw PromiError.persistence(.writeFailed)
            }
            return
        }

        // Append-only: read current, append, atomic replace
        let current: Data
        do {
            current = try Data(contentsOf: url)
        } catch {
            throw PromiError.persistence(.readFailed)
        }

        var merged = current
        merged.append(line)

        do {
            try AtomicFileWriter.writeAtomic(data: merged, to: url)
        } catch {
            throw PromiError.persistence(.writeFailed)
        }
    }
}
