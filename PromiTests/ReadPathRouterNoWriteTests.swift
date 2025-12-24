import XCTest
@testable import Promi

final class ReadPathRouterNoWriteTests: XCTestCase {

    func test_readSnapshot_doesNotCreateCanonicalStoreFile() throws {
        let suite = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let storeURL = try DataRoot.storeFileURL()
        if FileManager.default.fileExists(atPath: storeURL.path) {
            try FileManager.default.removeItem(at: storeURL)
        }

        _ = try ReadPathRouter.readSnapshot(defaults: defaults)

        XCTAssertFalse(FileManager.default.fileExists(atPath: storeURL.path))
    }
}

