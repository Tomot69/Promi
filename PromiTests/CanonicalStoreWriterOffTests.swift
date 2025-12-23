import XCTest
@testable import Promi

final class CanonicalStoreWriterOffTests: XCTestCase {

    func test_off_throwsAndDoesNotWriteStoreFile() throws {
        CanonicalStoreWritePolicy.isEnabled = false
        ShadowWritePolicy.isEnabled = false

        let storeURL = try DataRoot.storeFileURL()
        if FileManager.default.fileExists(atPath: storeURL.path) {
            try FileManager.default.removeItem(at: storeURL)
        }

        XCTAssertThrowsError(try CanonicalStoreWriter.writeCanonical(data: Data("x".utf8))) { error in
            XCTAssertEqual(error as? PromiError, .persistence(.writeFailed))
        }

        XCTAssertFalse(FileManager.default.fileExists(atPath: storeURL.path))
    }
}
