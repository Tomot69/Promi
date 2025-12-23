import Foundation

struct PromiStoreSnapshot: Codable, Equatable {
    let schemaVersion: Int
    let promis: [PromiItem]
    let bravos: [Bravo]
    let comments: [Comment]

    static func v1(promis: [PromiItem], bravos: [Bravo], comments: [Comment]) -> PromiStoreSnapshot {
        PromiStoreSnapshot(schemaVersion: 1, promis: promis, bravos: bravos, comments: comments)
    }
}
