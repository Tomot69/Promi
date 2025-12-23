import Foundation

enum JSONStoreError: Equatable {
    case decodeFailed
    case encodeFailed
    case unsupportedSchemaVersion(Int)
    case emptyData
}
