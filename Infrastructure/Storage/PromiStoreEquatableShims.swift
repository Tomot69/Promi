import Foundation

extension Bravo: Equatable {
    static func == (lhs: Bravo, rhs: Bravo) -> Bool {
        lhs.id == rhs.id &&
        lhs.promiId == rhs.promiId &&
        lhs.userId == rhs.userId &&
        lhs.createdAt == rhs.createdAt
    }
}

extension Comment: Equatable {
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        lhs.id == rhs.id &&
        lhs.promiId == rhs.promiId &&
        lhs.userId == rhs.userId &&
        lhs.text == rhs.text &&
        lhs.createdAt == rhs.createdAt
    }
}
