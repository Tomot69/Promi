import Foundation

struct AuditEvent: Codable, Equatable {
    let id: UUID
    let timestamp: Date
    let useCaseId: String
    let outcome: String
    let details: String?

    init(useCaseId: String, outcome: String, details: String?) throws {
        let trimmed = useCaseId.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            throw PromiError.validation(.empty)
        }
        self.id = UUID()
        self.timestamp = Date()
        self.useCaseId = trimmed
        self.outcome = outcome
        self.details = details
    }
}
