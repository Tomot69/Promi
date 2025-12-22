import XCTest
@testable import Promi

@MainActor
final class ReactionRulesTests: XCTestCase {

    func test_bravoAccepted() throws {
        try ReactionRules.ensureSingleBravo(.bravo)
    }
}
