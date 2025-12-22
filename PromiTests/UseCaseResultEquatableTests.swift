import XCTest
@testable import Promi

@MainActor
final class UseCaseResultEquatableTests: XCTestCase {

    func test_failureEquatable() {
        let a: UseCaseResult<AppTypes.DeletePromiOutput> = .failure(.persistence(.writeFailed))
        let b: UseCaseResult<AppTypes.DeletePromiOutput> = .failure(.persistence(.writeFailed))
        XCTAssertEqual(a, b)
    }
}
