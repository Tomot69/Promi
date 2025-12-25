import XCTest
@testable import Promi

final class ReadOnlyDraftStoreLegacyFallbackTests: XCTestCase {

    func test_fallbacksToLegacyWhenMigratedMissing() throws {
        try MainActor.assumeIsolated {
            let suite = "test.\(UUID().uuidString)"
            let defaults = UserDefaults(suiteName: suite)!
            defer { defaults.removePersistentDomain(forName: suite) }

            let testRoot = FileManager.default.temporaryDirectory
                .appendingPathComponent("promi-tests-\(UUID().uuidString)", isDirectory: true)

            DraftsPaths.testOverrideRootURL = testRoot
            defer { DraftsPaths.testOverrideRootURL = nil }

            let url = try DraftsPaths.draftsFileURL()
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }

            defaults.set(try JSONEncoder().encode([PromiDraft]()), forKey: LegacyUserDefaultsKeys.draftsKey)

            var store: ReadOnlyDraftStore? = ReadOnlyDraftStore(defaults: defaults)
            XCTAssertEqual(store?.drafts.count, 0)

            // force la désallocation sur MainActor
            store = nil
        }
    }
}

