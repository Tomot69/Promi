//
//  PromiTitleTests.swift
//  PromiTests
//
//  Created by MACBOOKPRO on 22/12/2025.
//

import XCTest
@testable import Promi

final class PromiTitleTests: XCTestCase {

    func test_trimApplied() throws {
        let title = try PromiTitle("  Bonjour  ")
        XCTAssertEqual(title.value, "Bonjour")
    }

    func test_emptyRejected() {
        XCTAssertThrowsError(try PromiTitle("   ")) { error in
            XCTAssertEqual(error as? PromiError, .validation(.empty))
        }
    }

    func test_tooLongRejected() {
        let raw = String(repeating: "a", count: DomainTokens.promiTitleMaxChars + 1)
        XCTAssertThrowsError(try PromiTitle(raw)) { error in
            XCTAssertEqual(
                error as? PromiError,
                .validation(.tooLong(
                    max: DomainTokens.promiTitleMaxChars,
                    got: DomainTokens.promiTitleMaxChars + 1
                ))
            )
        }
    }

    func test_validAccepted() throws {
        let raw = String(repeating: "a", count: DomainTokens.promiTitleMaxChars)
        let title = try PromiTitle(raw)
        XCTAssertEqual(title.value.count, DomainTokens.promiTitleMaxChars)
    }
}

