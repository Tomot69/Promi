import XCTest
@testable import Promi

final class ShadowStoreWriterOnTests: XCTestCase {

    func test_on_writesFile() throws {
        ShadowWritePolicy.isEnabled = true
        defer { ShadowWritePolicy.isEnabled = false }

        let url = try ShadowPaths.shadowStoreFileURL()
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }

        let data = Data("hello".utf8)
        try ShadowStoreWriter.writeShadow(data: data)

        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        XCTAssertEqual(try Data(contentsOf: url), data)
    }
}

