import XCTest
@testable import Promi

final class CanonicalStoreWriterOnTests: XCTestCase {

    func test_on_writesAtomicallyAndCreatesBackupOnSecondWrite() throws {
        CanonicalStoreWritePolicy.isEnabled = true
        ShadowWritePolicy.isEnabled = false
        defer { CanonicalStoreWritePolicy.isEnabled = false }

        let storeURL = try DataRoot.storeFileURL()
        if FileManager.default.fileExists(atPath: storeURL.path) {
            try FileManager.default.removeItem(at: storeURL)
        }
        let bakURL = storeURL.appendingPathExtension("bak")
        if FileManager.default.fileExists(atPath: bakURL.path) {
            try FileManager.default.removeItem(at: bakURL)
        }

        let first = Data("one".utf8)
        try CanonicalStoreWriter.writeCanonical(data: first)
        XCTAssertEqual(try Data(contentsOf: storeURL), first)

        let second = Data("two".utf8)
        try CanonicalStoreWriter.writeCanonical(data: second)

        XCTAssertTrue(FileManager.default.fileExists(atPath: bakURL.path))
        XCTAssertEqual(try Data(contentsOf: bakURL), first)
        XCTAssertEqual(try Data(contentsOf: storeURL), second)
    }
}
