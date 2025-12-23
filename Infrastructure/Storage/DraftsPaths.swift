import Foundation

enum DraftsPaths {

    static func draftsFileURL() throws -> URL {
        let base = try DataRoot.baseDirectory()
        return try AppFilePaths.fileURL(in: base, filename: "drafts.v1.json")
    }
}

