import Foundation

struct BravoKey: Hashable, Codable, Sendable {
    let promiId: UUID
    let localUserId: String

    init(promiId: UUID, localUserId: String) throws {
        let trimmed = localUserId.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            throw PromiError.validation(.empty)
        }
        self.promiId = promiId
        self.localUserId = trimmed
    }
}

