import Foundation

enum AtomicFileWriter {

    static func writeAtomic(data: Data, to url: URL) throws {
        let dir = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let tmpURL = url.appendingPathExtension("tmp")

        // 1) write tmp
        do {
            try data.write(to: tmpURL, options: .atomic)
        } catch {
            throw PromiError.persistence(.writeFailed)
        }

        // 2) validate post-write (read back)
        do {
            _ = try Data(contentsOf: tmpURL)
        } catch {
            // tmp is corrupt or unreadable -> do not replace final
            throw PromiError.persistence(.writeFailed)
        }

        // 3) backup existing -> .bak
        let bakURL = url.appendingPathExtension("bak")
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                if FileManager.default.fileExists(atPath: bakURL.path) {
                    try FileManager.default.removeItem(at: bakURL)
                }
                try FileManager.default.copyItem(at: url, to: bakURL)
            } catch {
                throw PromiError.persistence(.writeFailed)
            }
        }

        // 4) replace final with tmp (atomic replace)
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            try FileManager.default.moveItem(at: tmpURL, to: url)
        } catch {
            throw PromiError.persistence(.writeFailed)
        }
    }
}
