import XCTest
@testable import Promi

final class AtomicFileWriterTests: XCTestCase {

    func test_writeAtomic_createsFinalAndBackup() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url = try AppFilePaths.fileURL(in: dir, filename: "payload.json")

        let first = Data("one".utf8)
        try AtomicFileWriter.writeAtomic(data: first, to: url)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        XCTAssertEqual(try Data(contentsOf: url), first)

        let second = Data("two".utf8)
        try AtomicFileWriter.writeAtomic(data: second, to: url)

        let bakURL = url.appendingPathExtension("bak")
        XCTAssertTrue(FileManager.default.fileExists(atPath: bakURL.path))
        XCTAssertEqual(try Data(contentsOf: bakURL), first)
        XCTAssertEqual(try Data(contentsOf: url), second)
    }
}
