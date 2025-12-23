import Foundation

enum ShadowPaths {

    static func shadowStoreFileURL() throws -> URL {
        let base = try DataRoot.baseDirectory()
        return try AppFilePaths.fileURL(in: base, filename: "store.shadow.json")
    }
}
