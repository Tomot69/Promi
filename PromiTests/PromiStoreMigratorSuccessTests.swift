import XCTest
@testable import Promi

final class PromiStoreMigratorSuccessTests: XCTestCase {

    func test_migrate_success_writesFile() throws {
        let suite = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        defaults.set(try JSONEncoder().encode([PromiItem]()), forKey: LegacyUserDefaultsKeys.promisKey)
        defaults.set(try JSONEncoder().encode([Bravo]()), forKey: LegacyUserDefaultsKeys.bravosKey)
        defaults.set(try JSONEncoder().encode([Comment]()), forKey: LegacyUserDefaultsKeys.commentsKey)

        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url = try AppFilePaths.fileURL(in: dir, filename: "promiStore.v1.json")

        PromiStoreMigrator.isEnabled = true
        defer { PromiStoreMigrator.isEnabled = false }

        let result = try PromiStoreMigrator.migrate(from: defaults, to: url)

        switch result {
        case .ok:
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        default:
            XCTFail("Expected .ok")
        }
    }
}
