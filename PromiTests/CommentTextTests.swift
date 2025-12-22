//
//  CommentTextTests.swift
//  PromiTests
//
//  Created by MACBOOKPRO on 22/12/2025.
//

import XCTest
@testable import Promi

final class CommentTextTests: XCTestCase {

    func test_trimApplied() throws {
        let c = try CommentText("  Merci  ")
        XCTAssertEqual(c.value, "Merci")
    }

    func test_emptyRejected() {
        XCTAssertThrowsError(try CommentText("   ")) { error in
            XCTAssertEqual(error as? PromiError, .validation(.empty))
        }
    }

    func test_tooLongRejected() {
        let raw = String(repeating: "a", count: DomainTokens.commentMaxChars + 1)
        XCTAssertThrowsError(try CommentText(raw)) { error in
            XCTAssertEqual(
                error as? PromiError,
                .validation(.tooLong(
                    max: DomainTokens.commentMaxChars,
                    got: DomainTokens.commentMaxChars + 1
                ))
            )
        }
    }

    func test_240Accepted() throws {
        let raw = String(repeating: "a", count: DomainTokens.commentMaxChars)
        let c = try CommentText(raw)
        XCTAssertEqual(c.value.count, DomainTokens.commentMaxChars)
    }
}

