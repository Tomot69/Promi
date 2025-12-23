import XCTest
@testable import Promi

final class CanonicalStoreWriterAuditTests: XCTestCase {

    func test_auditAppendsOnFailureAndSuccess() throws {
        let auditURL = try DataRoot.auditFileURL()
        if FileManager.default.fileExists(atPath: auditURL.path) {
            try FileManager.default.removeItem(at: auditURL)
        }

        // 1) Failure path (disabled)
        CanonicalStoreWritePolicy.isEnabled = false
        ShadowWritePolicy.isEnabled = false
        XCTAssertThrowsError(try CanonicalStoreWriter.writeCanonical(data: Data("x".utf8)))

        let d1 = try Data(contentsOf: auditURL)
        XCTAssertTrue(d1.count > 0)

        // 2) Success path
        CanonicalStoreWritePolicy.isEnabled = true
        defer { CanonicalStoreWritePolicy.isEnabled = false }
        try CanonicalStoreWriter.writeCanonical(data: Data("yy".utf8))

        let d2 = try Data(contentsOf: auditURL)
        XCTAssertTrue(d2.count > d1.count)
    }
}
