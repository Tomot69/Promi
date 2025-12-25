import XCTest
@testable import Promi

final class ReadPathActivationGateAuditTests: XCTestCase {

    func test_recordAttempt_appendsAuditLine() throws {
        let auditURL = try DataRoot.auditFileURL()
        if FileManager.default.fileExists(atPath: auditURL.path) {
            try FileManager.default.removeItem(at: auditURL)
        }

        try ReadPathActivationGate.recordAttempt(decision: .notEnableable(reason: "x"))
        let d1 = try Data(contentsOf: auditURL)
        XCTAssertTrue(d1.count > 0)

        try ReadPathActivationGate.recordAttempt(decision: .enableable)
        let d2 = try Data(contentsOf: auditURL)
        XCTAssertTrue(d2.count > d1.count)
    }
}
