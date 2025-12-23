import XCTest
@testable import Promi

final class ShadowStoreWriterAuditTests: XCTestCase {

    func test_on_appendsAuditLine() throws {
        ShadowWritePolicy.isEnabled = true
        defer { ShadowWritePolicy.isEnabled = false }

        let auditURL = try DataRoot.auditFileURL()
        if FileManager.default.fileExists(atPath: auditURL.path) {
            try FileManager.default.removeItem(at: auditURL)
        }

        try ShadowStoreWriter.writeShadow(data: Data("a".utf8))
        let first = try Data(contentsOf: auditURL)

        try ShadowStoreWriter.writeShadow(data: Data("bb".utf8))
        let second = try Data(contentsOf: auditURL)

        XCTAssertTrue(second.count > first.count)
    }
}
