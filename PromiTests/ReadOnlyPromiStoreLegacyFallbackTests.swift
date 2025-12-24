import XCTest
@testable import Promi

final class ReadOnlyPromiStoreLegacyFallbackTests: XCTestCase {

    func test_fallbacksToLegacyWhenMigratedMissing() throws {
        let suite = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        // Ensure migrated file absent
        let url = try PromiStorePaths.promiStoreFileURL()
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }

        // Legacy valid empties
        defaults.set(try JSONEncoder().encode([PromiItem]()), forKey: LegacyUserDefaultsKeys.promisKey)
        defaults.set(try JSONEncoder().encode([Bravo]()), forKey: LegacyUserDefaultsKeys.bravosKey)
        defaults.set(try JSONEncoder().encode([Comment]()), forKey: LegacyUserDefaultsKeys.commentsKey)

        let store = ReadOnlyPromiStore(defaults: defaults)

        XCTAssertEqual(store.promis.count, 0)
        XCTAssertEqual(store.bravos.count, 0)
        XCTAssertEqual(store.comments.count, 0)
    }
}
