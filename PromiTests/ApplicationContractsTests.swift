import XCTest
@testable import Promi

@MainActor
final class ApplicationContractsTests: XCTestCase {

    func test_useCaseResultEquatable() {
        let a: UseCaseResult<NoopCreatePromi.Output> = .failure(.persistence(.writeFailed))
        let b: UseCaseResult<NoopCreatePromi.Output> = .failure(.persistence(.writeFailed))
        XCTAssertEqual(a, b)
    }
}

