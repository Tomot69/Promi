import XCTest
@testable import Promi

final class RawStoreDataReaderOKTests: XCTestCase {

    func test_read_ok_whenMainValidNonEmpty() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url = try AppFilePaths.fileURL(in: dir, filename: "store.json")

        try AtomicFileWriter.writeAtomic(data: Data("hello".utf8), to: url)

        let result = try RawStoreDataReader.read(from: url)

        switch result {
        case .ok(let data):
            XCTAssertEqual(data, Data("hello".utf8))
        default:
            XCTFail("Expected .ok")
        }
    }
}

