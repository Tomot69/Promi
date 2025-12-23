import Foundation

enum PromiStorePaths {

    static func promiStoreFileURL() throws -> URL {
        let base = try DataRoot.baseDirectory()
        return try AppFilePaths.fileURL(in: base, filename: "promiStore.v1.json")
    }
}
