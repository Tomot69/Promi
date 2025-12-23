import XCTest
@testable import Promi

final class JSONStoreSchemaTests: XCTestCase {

    private struct Dummy: Codable, Equatable {
        let message: String
    }

    func test_corrupted_whenUnsupportedSchemaVersion() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url = try AppFilePaths.fileURL(in: dir, filename: "dummy.json")

        let env = VersionedEnvelope(schemaVersion: 99, updatedAt: Date(timeIntervalSince1970: 0), value: Dummy(message: "x"))
        try JSONStore.write(envelope: env, to: url)

        let result: RecoveryResult<VersionedEnvelope<Dummy>> = try JSONStore.read(from: url, expectedSchemaVersion: 1)

        switch result {
        case .corrupted:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected .corrupted")
        }
    }
}
