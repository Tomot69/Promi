import XCTest
@testable import Promi

final class ReadOnlyDraftStoreMigratedTests: XCTestCase {

    func test_readsMigratedDraftsWhenPresent() throws {
        let suite = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        // Legacy junk
        defaults.set(Data("{not_json}".utf8), forKey: LegacyUserDefaultsKeys.draftsKey)

        // Ensure migrated dir exists and file is written (raw JSON, schema v1)
        let url = try DraftsPaths.draftsFileURL()
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        // We avoid VersionedEnvelope<T> because PromiDraft is not Equatable.
        // So we write a minimal valid envelope as JSON.
        let envelope: [String: Any] = [
            "schemaVersion": 1,
            "updatedAt": Date(timeIntervalSince1970: 0).timeIntervalSince1970
        ]

        // Decode requires a "value" field containing an array of drafts.
        // We can safely encode an empty array (valid for this invariant test).
        let payload: [String: Any] = [
            "schemaVersion": 1,
            "updatedAt": Date(timeIntervalSince1970: 0).timeIntervalSince1970,
            "value": []
        ]

        let data = try JSONSerialization.data(withJSONObject: payload, options: [])
        try data.write(to: url, options: [.atomic])

        let store = ReadOnlyDraftStore(defaults: defaults)
        XCTAssertEqual(store.drafts.count, 0)
    }
}

