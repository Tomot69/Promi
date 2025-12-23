import XCTest
@testable import Promi

final class RecoveryReaderBackupTests: XCTestCase {

    func test_recoveredFromBackup_when_main_corrupt() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url = try AppFilePaths.fileURL(in: dir, filename: "state.json")

        let first = Data("first".utf8)
        try AtomicFileWriter.writeAtomic(data: first, to: url)

        let second = Data("second".utf8)
        try AtomicFileWriter.writeAtomic(data: second, to: url)

        // Corrupt main
        try FileManager.default.removeItem(at: url)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)

        let result = try RecoveryReader.readOrRecover(from: url)

        switch result {
        case .recoveredFromBackup(let recovered):
            XCTAssertEqual(recovered, first)
        default:
            XCTFail("Expected .recoveredFromBackup")
        }
    }
}

