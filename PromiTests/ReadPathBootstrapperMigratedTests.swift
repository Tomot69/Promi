import XCTest
@testable import Promi

final class ReadPathBootstrapperMigratedTests: XCTestCase {

    func test_bootstrapperHydratesFromMigratedWhenPresent() async throws {
        try await MainActor.run {
            let suite = "test.\(UUID().uuidString)"
            let defaults = UserDefaults(suiteName: suite)!
            defer { defaults.removePersistentDomain(forName: suite) }

            // Ensure legacy is junk so migrated must win
            defaults.set(Data("{not_json}".utf8), forKey: LegacyUserDefaultsKeys.promisKey)
            defaults.set(Data("{not_json}".utf8), forKey: LegacyUserDefaultsKeys.bravosKey)
            defaults.set(Data("{not_json}".utf8), forKey: LegacyUserDefaultsKeys.commentsKey)
            defaults.set(Data("{not_json}".utf8), forKey: LegacyUserDefaultsKeys.draftsKey)

            // Write migrated promiStore snapshot (schemaVersion 1), updatedAt ISO8601 string.
            let promiStorePayload: [String: Any] = [
                "schemaVersion": 1,
                "updatedAt": "1970-01-01T00:00:00Z",
                "value": [
                    "promis": [],
                    "bravos": [],
                    "comments": []
                ]
            ]
            let promiStoreData = try JSONSerialization.data(withJSONObject: promiStorePayload, options: [])
            let promiStoreURL = try PromiStorePaths.promiStoreFileURL()
            try FileManager.default.createDirectory(at: promiStoreURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try promiStoreData.write(to: promiStoreURL, options: [.atomic])

            // Write migrated drafts (schemaVersion 1), updatedAt ISO8601 string.
            let draftsPayload: [String: Any] = [
                "schemaVersion": 1,
                "updatedAt": "1970-01-01T00:00:00Z",
                "value": []
            ]
            let draftsData = try JSONSerialization.data(withJSONObject: draftsPayload, options: [])
            let draftsURL = try DraftsPaths.draftsFileURL()
            try FileManager.default.createDirectory(at: draftsURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try draftsData.write(to: draftsURL, options: [.atomic])

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

