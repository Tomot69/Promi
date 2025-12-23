import XCTest
@testable import Promi

final class LegacyDraftsReaderTests: XCTestCase {

    func test_lenient_readsFromExactKey_withEmptyArrayRoundTrip() throws {
        let suite = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let drafts: [PromiDraft] = []
        let data = try JSONEncoder().encode(drafts)
        defaults.set(data, forKey: LegacyUserDefaultsKeys.draftsKey)

        let read = LegacyDraftsReader.readLenient(from: defaults)
        XCTAssertEqual(read.count, drafts.count)

        let strict = LegacyDraftsReader.readStrict(from: defaults)
        switch strict {
        case .ok(let decoded):
            XCTAssertEqual(decoded.count, drafts.count)
        default:
            XCTFail("Expected .ok")
        }
    }
}

