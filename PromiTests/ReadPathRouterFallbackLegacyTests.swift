import XCTest
@testable import Promi

final class ReadPathRouterFallbackLegacyTests: XCTestCase {

    func test_fallbacksToLegacy_whenMigratedMissing() throws {
        let suite = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        // Ensure migrated file absent
        let url = try DraftsPaths.draftsFileURL()
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }

        // Legacy contains empty array (valid)
        defaults.set(try JSONEncoder().encode([PromiDraft]()), forKey: LegacyUserDefaultsKeys.draftsKey)

        let snap = try ReadPathRouter.readSnapshot(defaults: defaults)
        XCTAssertEqual(snap.drafts.count, 0)
    }
}

