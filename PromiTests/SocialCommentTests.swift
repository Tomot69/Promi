import XCTest
@testable import Promi

final class SocialCommentTests: XCTestCase {

    func test_commentValidatedViaCommentText() throws {
        let c = try SocialRules.validateComment("  Merci  ")
        XCTAssertEqual(c.value, "Merci")
    }
}
