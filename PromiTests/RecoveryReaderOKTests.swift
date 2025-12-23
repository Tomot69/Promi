import XCTest
@testable import Promi

final class RecoveryReaderOKTests: XCTestCase {

    func test_ok_when_main_valid() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url = try AppFilePaths.fileURL(in: dir, filename: "state.json")

        let data = Data("ok".utf8)
        try AtomicFileWriter.writeAtomic(data: data, to: url)

        let result = try RecoveryReader.readOrRecover(from: url)

        switch result {
        case .ok(let read):
            XCTAssertEqual(read, data)
        default:
            XCTFail("Expected .ok")
        }
    }
}
