import Foundation

enum SocialRules {

    static func ensureUniqueBravo(existing: Set<BravoKey>, newKey: BravoKey) throws {
        if existing.contains(newKey) {
            throw PromiError.validation(.outOfRange(min: 0, max: 0, got: 1))
        }
    }

    static func validateComment(_ raw: String) throws -> CommentText {
        return try CommentText(raw)
    }
}
