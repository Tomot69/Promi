import Foundation

enum PromiStorePaths {

    /// Override utilisé uniquement par les tests pour isoler les fichiers par test.
    /// Ne pas utiliser en production.
    static var testOverrideRootURL: URL?

    static func promiStoreFileURL() throws -> URL {
        if let root = testOverrideRootURL {
            return root.appendingPathComponent("promiStore.v1.json")
        }

        let base = try DataRoot.baseDirectory()
        return try AppFilePaths.fileURL(in: base, filename: "promiStore.v1.json")
    }
}

