import XCTest
@testable import Promi

@MainActor
final class SocialBravoTests: XCTestCase {

    func test_uniqueBravoAccepted() throws {
        let key = try BravoKey(promiId: UUID(), localUserId: "user")
        var set = Set<BravoKey>()
        try SocialRules.ensureUniqueBravo(existing: set, newKey: key)
        set.insert(key)
        XCTAssertTrue(set.contains(key))
    }

    func test_duplicateBravoRejected() throws {
        let id = UUID()
        let key = try BravoKey(promiId: id, localUserId: "user")
        let set: Set<BravoKey> = [key]

        XCTAssertThrowsError(try SocialRules.ensureUniqueBravo(existing: set, newKey: key)) { error in
            XCTAssertEqual(error as? PromiError, .validation(.outOfRange(min: 0, max: 0, got: 1)))
        }
    }
}

