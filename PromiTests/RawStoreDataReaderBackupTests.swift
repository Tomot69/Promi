import XCTest
@testable import Promi

final class RawStoreDataReaderBackupTests: XCTestCase {

    func test_read_recoveredFromBackup_whenMainUnreadable_bakValid() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url = try AppFilePaths.fileURL(in: dir, filename: "store.json")

        // First write establishes main
        try AtomicFileWriter.writeAtomic(data: Data("first".utf8), to: url)

        // Second write creates .bak containing "first"
        try AtomicFileWriter.writeAtomic(data: Data("second".utf8), to: url)

        // Make main unreadable deterministically
        try FileManager.default.removeItem(at: url)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)

        let result = try RawStoreDataReader.read(from: url)

        switch result {
        case .recoveredFromBackup(let data):
            XCTAssertEqual(data, Data("first".utf8))
        default:
            XCTFail("Expected .recoveredFromBackup")
        }
    }
}
