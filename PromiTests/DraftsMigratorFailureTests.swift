import XCTest
@testable import Promi

final class DraftsMigratorFailureTests: XCTestCase {

    func test_migrate_corrupted_doesNotWriteFile() throws {
        let suite = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        defaults.set(Data("{not_json}".utf8), forKey: LegacyUserDefaultsKeys.draftsKey)

        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url = try AppFilePaths.fileURL(in: dir, filename: "drafts.v1.json")

        DraftsMigrator.isEnabled = true
        defer { DraftsMigrator.isEnabled = false }

        let result = try DraftsMigrator.migrate(from: defaults, to: url)

        switch result {
        case .corrupted:
            XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
        default:
            XCTFail("Expected .corrupted")
        }
    }

    func test_migrate_disabled_returnsCorrupted_andDoesNotWrite() throws {
        let suite = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        DraftsMigrator.isEnabled = false

        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url = try AppFilePaths.fileURL(in: dir, filename: "drafts.v1.json")

        let result = try DraftsMigrator.migrate(from: defaults, to: url)

        switch result {
        case .corrupted:
            XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
        default:
            XCTFail("Expected .corrupted")
        }
    }
}

