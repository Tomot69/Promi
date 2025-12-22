import Foundation

enum AppTypes {

    struct PromiID: Equatable, Hashable, Codable {
        let value: UUID
        init(_ value: UUID) { self.value = value }
    }

    // Inputs/Outputs intentionally contain only primitives/value wrappers.
    // They do NOT reference Stores/Views/Infra.

    struct CreatePromiInput: Equatable, Codable {
        let titleRaw: String
    }
    struct CreatePromiOutput: Equatable, Codable {
        let id: PromiID
    }

    struct EditPromiInput: Equatable, Codable {
        let id: PromiID
        let titleRaw: String
    }
    struct EditPromiOutput: Equatable, Codable { }

    struct DeletePromiInput: Equatable, Codable {
        let id: PromiID
    }
    struct DeletePromiOutput: Equatable, Codable { }

    struct MarkDoneInput: Equatable, Codable {
        let id: PromiID
    }
    struct MarkDoneOutput: Equatable, Codable { }

    struct ReopenPromiInput: Equatable, Codable {
        let id: PromiID
    }
    struct ReopenPromiOutput: Equatable, Codable { }

    struct AddBravoInput: Equatable, Codable {
        let id: PromiID
        let localUserIdRaw: String
    }
    struct AddBravoOutput: Equatable, Codable { }

    struct AddCommentInput: Equatable, Codable {
        let id: PromiID
        let commentRaw: String
    }
    struct AddCommentOutput: Equatable, Codable { }
}
