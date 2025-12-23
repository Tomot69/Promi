import XCTest
@testable import Promi

final class DraftsMigratorRoundTripTests: XCTestCase {

    func test_roundTrip_readBackViaJSONStore() throws {
        let suite = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let drafts: [PromiDraft] = []
        let legacy = try JSONEncoder().encode(drafts)
        defaults.set(legacy, forKey: LegacyUserDefaultsKeys.draftsKey)

        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url = try AppFilePaths.fileURL(in: dir, filename: "drafts.v1.json")

        DraftsMigrator.isEnabled = true
        defer { DraftsMigrator.isEnabled = false }

        _ = try DraftsMigrator.migrate(from: defaults, to: url)

        let read: RecoveryResult<VersionedEnvelope<Data>> = try JSONStore.read(from: url, expectedSchemaVersion: 1)

        switch read {
        case .ok(let env):
            XCTAssertEqual(env.schemaVersion, 1)
            XCTAssertEqual(env.value, legacy)
        default:
            XCTFail("Expected .ok")
        }
    }
}

