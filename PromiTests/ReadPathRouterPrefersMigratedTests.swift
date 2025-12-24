import XCTest
@testable import Promi

final class ReadPathRouterPrefersMigratedTests: XCTestCase {

    private struct CodableEnvelope<T: Codable>: Codable {
        let schemaVersion: Int
        let updatedAt: Date
        let value: T
    }

    func test_prefersMigrated_whenFilesPresent() throws {
        let suite = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        // Legacy has junk -> should be ignored if migrated present
        defaults.set(Data("{not_json}".utf8), forKey: LegacyUserDefaultsKeys.draftsKey)

        // Write migrated drafts file (versioned envelope v1) WITHOUT VersionedEnvelope.
        let drafts = [PromiDraft()]
        let env = CodableEnvelope(schemaVersion: 1, updatedAt: Date(timeIntervalSince1970: 0), value: drafts)

        let data = try JSONEncoder().encode(env)
        let url = try DraftsPaths.draftsFileURL()
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: url, options: [.atomic])

        let snap = try ReadPathRouter.readSnapshot(defaults: defaults)
        XCTAssertEqual(snap.drafts.count, drafts.count)
    }
}

