import XCTest
@testable import Promi

final class ReadOnlyPromiStoreLegacyFallbackTests: XCTestCase {

    func test_fallbacksToLegacyWhenMigratedMissing() throws {
        try MainActor.assumeIsolated {
            let suite = "test.\(UUID().uuidString)"
            let defaults = UserDefaults(suiteName: suite)!
            defer { defaults.removePersistentDomain(forName: suite) }

            let testRoot = FileManager.default.temporaryDirectory
                .appendingPathComponent("promi-tests-\(UUID().uuidString)", isDirectory: true)

            PromiStorePaths.testOverrideRootURL = testRoot
            defer { PromiStorePaths.testOverrideRootURL = nil }

            let url = try PromiStorePaths.promiStoreFileURL()
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }

            defaults.set(try JSONEncoder().encode([PromiItem]()), forKey: LegacyUserDefaultsKeys.promisKey)
            defaults.set(try JSONEncoder().encode([Bravo]()), forKey: LegacyUserDefaultsKeys.bravosKey)
            defaults.set(try JSONEncoder().encode([Comment]()), forKey: LegacyUserDefaultsKeys.commentsKey)

            var store: ReadOnlyPromiStore? = ReadOnlyPromiStore(defaults: defaults)
            XCTAssertEqual(store?.promis.count, 0)
            XCTAssertEqual(store?.bravos.count, 0)
            XCTAssertEqual(store?.comments.count, 0)
            store = nil
        }
    }
}

