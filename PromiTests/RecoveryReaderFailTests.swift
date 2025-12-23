import XCTest
@testable import Promi

final class RecoveryReaderFailTests: XCTestCase {

    func test_corrupted_when_main_and_backup_unreadable() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url = try AppFilePaths.fileURL(in: dir, filename: "state.json")

        let result = try RecoveryReader.readOrRecover(from: url)

        switch result {
        case .corrupted:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected .corrupted")
        }
    }
}

