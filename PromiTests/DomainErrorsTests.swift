import XCTest
@testable import Promi

final class DomainErrorsTests: XCTestCase {

    func testPromiErrorEquatable_identicalErrorsAreEqual() {
        let error1 = PromiError.validation(.empty)
        let error2 = PromiError.validation(.empty)

        XCTAssertEqual(error1, error2)
    }

    func testPromiErrorEquatable_differentErrorsAreNotEqual() {
        let error1 = PromiError.validation(.empty)
        let error2 = PromiError.persistence(.readFailed)

        XCTAssertNotEqual(error1, error2)
    }
}

