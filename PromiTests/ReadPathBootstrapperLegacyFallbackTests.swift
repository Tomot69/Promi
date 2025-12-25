import XCTest
@testable import Promi

final class ReadPathBootstrapperLegacyFallbackTests: XCTestCase {

    func test_bootstrapperHydratesFromLegacyWhenMigratedMissing() async throws {
        try await MainActor.run {
            let suite = "test.\(UUID().uuidString)"
            let defaults = UserDefaults(suiteName: suite)!
            defer { defaults.removePersistentDomain(forName: suite) }

            // Ensure migrated files absent
            let purl = try PromiStorePaths.promiStoreFileURL()
            if FileManager.default.fileExists(atPath: purl.path) { try FileManager.default.removeItem(at: purl) }
            let durl = try DraftsPaths.draftsFileURL()
            if FileManager.default.fileExists(atPath: durl.path) { try FileManager.default.removeItem(at: durl) }

            // Legacy valid empties for promiStore.
            defaults.set(try JSONEncoder().encode([PromiItem]()), forKey: LegacyUserDefaultsKeys.promisKey)
            defaults.set(try JSONEncoder().encode([Bravo]()), forKey: LegacyUserDefaultsKeys.bravosKey)
            defaults.set(try JSONEncoder().encode([Comment]()), forKey: LegacyUserDefaultsKeys.commentsKey)
            // draftsKey intentionally absent -> lenient legacy should yield []

            let promiStore = PromiStore()
            let draftStore = DraftStore()

            FeatureFlags.useReadPathBootstrapperOnLaunch = true
            defer { FeatureFlags.useReadPathBootstrapperOnLaunch = false }

            ReadPathBootstrapper.applyIfEnabled(defaults: defaults, promiStore: promiStore, draftStore: draftStore)

            XCTAssertEqual(promiStore.promis.count, 0)
            XCTAssertEqual(promiStore.bravos.count, 0)
            XCTAssertEqual(promiStore.comments.count, 0)
            XCTAssertEqual(draftStore.drafts.count, 0)
        }
    }
}

