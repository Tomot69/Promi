import XCTest
@testable import Promi

final class PromiStoreMigratorDuplicateBravoTests: XCTestCase {

    func test_migrate_duplicateBravo_doesNotWriteFile() throws {
        let suite = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        defaults.set(try JSONEncoder().encode([PromiItem]()), forKey: LegacyUserDefaultsKeys.promisKey)
        defaults.set(try JSONEncoder().encode([Comment]()), forKey: LegacyUserDefaultsKeys.commentsKey)

        let pid = UUID()
        let b1 = Bravo(promiId: pid, userId: "user")
        let b2 = Bravo(promiId: pid, userId: "user")
        defaults.set(try JSONEncoder().encode([b1, b2]), forKey: LegacyUserDefaultsKeys.bravosKey)

        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url = try AppFilePaths.fileURL(in: dir, filename: "promiStore.v1.json")

        PromiStoreMigrator.isEnabled = true
        defer { PromiStoreMigrator.isEnabled = false }

        let result = try PromiStoreMigrator.migrate(from: defaults, to: url)

        switch result {
        case .corrupted:
            XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
        default:
            XCTFail("Expected .corrupted")
        }
    }
}
