import XCTest
@testable import Caffeine

final class PowerManagerTests: XCTestCase {
    func testInitialState() {
        let powerManager = PowerManager()
        XCTAssertFalse(powerManager.isCaffeineEnabled)
    }
}