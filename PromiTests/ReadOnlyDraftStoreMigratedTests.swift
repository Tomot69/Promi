import XCTest
@testable import Promi

final class ReadOnlyDraftStoreMigratedTests: XCTestCase {

    func test_readsMigratedDraftsWhenPresent() throws {
        try MainActor.assumeIsolated {
            let suite = "test.\(UUID().uuidString)"
            let defaults = UserDefaults(suiteName: suite)!
            defer { defaults.removePersistentDomain(forName: suite) }

            let testRoot = FileManager.default.temporaryDirectory
                .appendingPathComponent("promi-tests-\(UUID().uuidString)", isDirectory: true)

            DraftsPaths.testOverrideRootURL = testRoot
            defer { DraftsPaths.testOverrideRootURL = nil }

            defaults.set(Data("{not_json}".utf8), forKey: LegacyUserDefaultsKeys.draftsKey)

            let payload: [String: Any] = [
                "schemaVersion": 1,
                "updatedAt": 0,
                "value": []
            ]

            let data = try JSONSerialization.data(withJSONObject: payload, options: [])
            let url = try DraftsPaths.draftsFileURL()

            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            try data.write(to: url, options: [.atomic])

            var store: ReadOnlyDraftStore? = ReadOnlyDraftStore(defaults: defaults)
            XCTAssertEqual(store?.drafts.count, 0)
            store = nil
        }
    }
}

