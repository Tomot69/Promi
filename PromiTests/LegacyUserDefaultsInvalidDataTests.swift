import XCTest
@testable import Promi

final class LegacyUserDefaultsInvalidDataTests: XCTestCase {

    func test_invalidData_lenientReturnsEmpty_strictReturnsCorrupted() throws {
        let suite = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let junk = Data("{not_json}".utf8)
        defaults.set(junk, forKey: LegacyUserDefaultsKeys.draftsKey)

        XCTAssertEqual(LegacyDraftsReader.readLenient(from: defaults).count, 0)

        let strict = LegacyDraftsReader.readStrict(from: defaults)
        switch strict {
        case .corrupted:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected .corrupted")
        }
    }
}

