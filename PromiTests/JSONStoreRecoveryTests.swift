import XCTest
@testable import Promi

final class JSONStoreRecoveryTests: XCTestCase {

    private struct Dummy: Codable, Equatable {
        let message: String
    }

    func test_recoverFromBackup_whenMainUnreadable_bakValid() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url = try AppFilePaths.fileURL(in: dir, filename: "dummy.json")

        let first = VersionedEnvelope(schemaVersion: 1, updatedAt: Date(timeIntervalSince1970: 1), value: Dummy(message: "first"))
        try JSONStore.write(envelope: first, to: url)

        let second = VersionedEnvelope(schemaVersion: 1, updatedAt: Date(timeIntervalSince1970: 2), value: Dummy(message: "second"))
        try JSONStore.write(envelope: second, to: url)

        // rendre le main illisible de façon déterministe : remplacer par un dossier
        try FileManager.default.removeItem(at: url)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)

        let result: RecoveryResult<VersionedEnvelope<Dummy>> = try JSONStore.read(from: url, expectedSchemaVersion: 1)

        switch result {
        case .recoveredFromBackup(let decoded):
            XCTAssertEqual(decoded.value, first.value)
            XCTAssertEqual(decoded.updatedAt, first.updatedAt)
        default:
            XCTFail("Expected .recoveredFromBackup")
        }
    }
}
