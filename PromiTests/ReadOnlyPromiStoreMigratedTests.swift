import XCTest
@testable import Promi

final class ReadOnlyPromiStoreMigratedTests: XCTestCase {

    func test_readsMigratedPromiStoreWhenPresent() throws {
        let suite = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        // Legacy junk (should be ignored if migrated present)
        defaults.set(Data("{not_json}".utf8), forKey: LegacyUserDefaultsKeys.promisKey)
        defaults.set(Data("{not_json}".utf8), forKey: LegacyUserDefaultsKeys.bravosKey)
        defaults.set(Data("{not_json}".utf8), forKey: LegacyUserDefaultsKeys.commentsKey)

        // Create migrated promiStore file with an empty v1 envelope (no Equatable required).
        let payload: [String: Any] = [
            "schemaVersion": 1,
            "updatedAt": 0,
            "value": [
                "promis": [],
                "bravos": [],
                "comments": []
            ]
        ]

        let data = try JSONSerialization.data(withJSONObject: payload, options: [])
        let url = try PromiStorePaths.promiStoreFileURL()
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: url, options: [.atomic])

        let store = ReadOnlyPromiStore(defaults: defaults)

        XCTAssertEqual(store.promis.count, 0)
        XCTAssertEqual(store.bravos.count, 0)
        XCTAssertEqual(store.comments.count, 0)
    }
}
