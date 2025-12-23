import XCTest
@testable import Promi

final class RawStoreDataReaderFailTests: XCTestCase {

    func test_read_corrupted_whenMainAndBackupMissing() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url = try AppFilePaths.fileURL(in: dir, filename: "store.json")

        let result = try RawStoreDataReader.read(from: url)

        switch result {
        case .corrupted:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected .corrupted")
        }
    }

    func test_read_corrupted_whenMainEmpty() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url = try AppFilePaths.fileURL(in: dir, filename: "store.json")

        try AtomicFileWriter.writeAtomic(data: Data(), to: url)

        let result = try RawStoreDataReader.read(from: url)

        switch result {
        case .corrupted:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected .corrupted")
        }
    }
}
