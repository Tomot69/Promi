import XCTest
@testable import Promi

final class ReadOnlyPromiStoreMigratedTests: XCTestCase {

    func test_readsMigratedPromiStoreWhenPresent() throws {
        try MainActor.assumeIsolated {
            let suite = "test.\(UUID().uuidString)"
            let defaults = UserDefaults(suiteName: suite)!
            defer { defaults.removePersistentDomain(forName: suite) }

            let testRoot = FileManager.default.temporaryDirectory
                .appendingPathComponent("promi-tests-\(UUID().uuidString)", isDirectory: true)

            PromiStorePaths.testOverrideRootURL = testRoot
            defer { PromiStorePaths.testOverrideRootURL = nil }

            defaults.set(Data("{not_json}".utf8), forKey: LegacyUserDefaultsKeys.promisKey)
            defaults.set(Data("{not_json}".utf8), forKey: LegacyUserDefaultsKeys.bravosKey)
            defaults.set(Data("{not_json}".utf8), forKey: LegacyUserDefaultsKeys.commentsKey)

            let payload: [String: Any] = [
                "schemaVersion": 1,
                "updatedAt": 0,
                "value": [
                    "schemaVersion": 1,
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
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            try data.write(to: url, options: [.atomic])

            var store: ReadOnlyPromiStore? = ReadOnlyPromiStore(defaults: defaults)
            XCTAssertEqual(store?.promis.count, 0)
            XCTAssertEqual(store?.bravos.count, 0)
            XCTAssertEqual(store?.comments.count, 0)
            store = nil
        }
    }
}

