import XCTest
@testable import Promi

final class FeatureFlagsDefaultTests: XCTestCase {

    func test_flagDefaultIsOff() {
        XCTAssertFalse(FeatureFlags.useReadPathBootstrapperOnLaunch)
    }
}
