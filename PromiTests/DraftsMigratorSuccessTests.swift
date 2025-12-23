import XCTest
@testable import Promi

final class DraftsMigratorSuccessTests: XCTestCase {

    func test_migrate_success_writesFile() throws {
        let suite = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        // Prepare legacy drafts: empty array is valid JSON and requires no initializer.
        let drafts: [PromiDraft] = []
        let legacy = try JSONEncoder().encode(drafts)
        defaults.set(legacy, forKey: LegacyUserDefaultsKeys.draftsKey)

        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url = try AppFilePaths.fileURL(in: dir, filename: "drafts.v1.json")

        DraftsMigrator.isEnabled = true
        defer { DraftsMigrator.isEnabled = false }

        let result = try DraftsMigrator.migrate(from: defaults, to: url)

        switch result {
        case .ok:
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        default:
            XCTFail("Expected .ok")
        }
    }
}

