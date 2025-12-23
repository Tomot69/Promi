import XCTest
@testable import Promi

final class DataRootTests: XCTestCase {

    func test_pathsAreDeterministicAndCreatable() throws {
        let base = try DataRoot.baseDirectory()
        XCTAssertTrue(FileManager.default.fileExists(atPath: base.path))

        let store = try DataRoot.storeFileURL()
        XCTAssertTrue(store.path.contains("promi"))
        XCTAssertTrue(store.lastPathComponent == "store.json")

        let audit = try DataRoot.auditFileURL()
        XCTAssertTrue(audit.path.contains("promi"))
        XCTAssertTrue(audit.lastPathComponent == "audit.jsonl")
    }
}
