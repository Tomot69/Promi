import XCTest
@testable import Promi

final class LegacyPromiStoreReaderTests: XCTestCase {

    func test_lenient_readsAllCollectionsFromExactKeys_withEmptyArrays() throws {
        let suite = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let promis: [PromiItem] = []
        let bravos: [Bravo] = []
        let comments: [Comment] = []

        defaults.set(try JSONEncoder().encode(promis), forKey: LegacyUserDefaultsKeys.promisKey)
        defaults.set(try JSONEncoder().encode(bravos), forKey: LegacyUserDefaultsKeys.bravosKey)
        defaults.set(try JSONEncoder().encode(comments), forKey: LegacyUserDefaultsKeys.commentsKey)

        XCTAssertEqual(LegacyPromiStoreReader.readPromisLenient(from: defaults).count, promis.count)
        XCTAssertEqual(LegacyPromiStoreReader.readBravosLenient(from: defaults).count, bravos.count)
        XCTAssertEqual(LegacyPromiStoreReader.readCommentsLenient(from: defaults).count, comments.count)

        let strict = LegacyPromiStoreReader.readAllStrict(from: defaults)
        switch strict {
        case .ok(let triple):
            XCTAssertEqual(triple.promis.count, promis.count)
            XCTAssertEqual(triple.bravos.count, bravos.count)
            XCTAssertEqual(triple.comments.count, comments.count)
        default:
            XCTFail("Expected .ok")
        }
    }
}

