import XCTest
@testable import Promi

final class AuditLoggerTests: XCTestCase {

    func test_append_isAppendOnly() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url = try AppFilePaths.fileURL(in: dir, filename: "audit.jsonl")

        let e1 = try AuditEvent(useCaseId: "UC-TEST", outcome: "success", details: nil)
        try AuditLogger.append(event: e1, to: url)

        let d1 = try Data(contentsOf: url)
        XCTAssertTrue(d1.count > 0)

        let e2 = try AuditEvent(useCaseId: "UC-TEST", outcome: "failure", details: "x")
        try AuditLogger.append(event: e2, to: url)

        let d2 = try Data(contentsOf: url)
        XCTAssertTrue(d2.count > d1.count) // append-only growth
    }
}
