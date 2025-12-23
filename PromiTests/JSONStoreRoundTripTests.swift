import XCTest
@testable import Promi

final class JSONStoreRoundTripTests: XCTestCase {

    private struct Dummy: Codable, Equatable {
        let message: String
        let count: Int
    }

    func test_roundTrip_encodeDecodeEquality() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url = try AppFilePaths.fileURL(in: dir, filename: "dummy.json")

        let env = VersionedEnvelope(schemaVersion: 1, updatedAt: Date(timeIntervalSince1970: 0), value: Dummy(message: "hi", count: 2))
        try JSONStore.write(envelope: env, to: url)

        let result: RecoveryResult<VersionedEnvelope<Dummy>> = try JSONStore.read(from: url, expectedSchemaVersion: 1)

        switch result {
        case .ok(let decoded):
            XCTAssertEqual(decoded.schemaVersion, 1)
            XCTAssertEqual(decoded.updatedAt, Date(timeIntervalSince1970: 0))
            XCTAssertEqual(decoded.value, env.value)
        default:
            XCTFail("Expected .ok")
        }
    }
}
