import XCTest
@testable import Promi

final class ShadowStoreWriterOffTests: XCTestCase {

    func test_off_doesNotWriteFile() throws {
        ShadowWritePolicy.isEnabled = false

        let url = try ShadowPaths.shadowStoreFileURL()
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }

        try ShadowStoreWriter.writeShadow(data: Data("x".utf8))
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
    }
}
