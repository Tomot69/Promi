import Foundation

enum DraftsPaths {

    /// Override utilisé uniquement par les tests pour isoler les fichiers par test.
    /// Ne pas utiliser en production.
    static var testOverrideRootURL: URL?

    static func draftsFileURL() throws -> URL {
        if let root = testOverrideRootURL {
            return root.appendingPathComponent("drafts.v1.json")
        }

        let base = try DataRoot.baseDirectory()
        return try AppFilePaths.fileURL(in: base, filename: "drafts.v1.json")
    }
}

