import Foundation

struct VersionedEnvelope<T: Codable>: Codable, Equatable where T: Equatable {
    let schemaVersion: Int
    let updatedAt: Date
    let value: T

    init(schemaVersion: Int, updatedAt: Date, value: T) {
        self.schemaVersion = schemaVersion
        self.updatedAt = updatedAt
        self.value = value
    }
}
