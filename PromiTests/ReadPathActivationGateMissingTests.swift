import XCTest
@testable import Promi

final class ReadPathActivationGateMissingTests: XCTestCase {

    func test_preflight_notEnableable_whenMigratedMissing() throws {
        // Ensure migrated files absent
        let purl = try PromiStorePaths.promiStoreFileURL()
        if FileManager.default.fileExists(atPath: purl.path) { try FileManager.default.removeItem(at: purl) }
        let durl = try DraftsPaths.draftsFileURL()
        if FileManager.default.fileExists(atPath: durl.path) { try FileManager.default.removeItem(at: durl) }

        let decision = ReadPathActivationGate.preflight(defaults: .standard)
        switch decision {
        case .notEnableable:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected .notEnableable")
        }
    }
}
