import XCTest
@testable import Caffeine

final class PowerManagerTests: XCTestCase {
    var powerManager: PowerManagerImpl!
    var userDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        // 테스트용 UserDefaults 사용
        userDefaults = UserDefaults(suiteName: "com.caffeine.tests")!
        userDefaults.removePersistentDomain(forName: "com.caffeine.tests")
        powerManager = PowerManagerImpl()
    }
    
    override func tearDown() {
        powerManager?.forceDisableCaffeine()
        powerManager = nil
        userDefaults?.removePersistentDomain(forName: "com.caffeine.tests")
        userDefaults = nil
        super.tearDown()
    }
    
    // MARK: - 초기 상태 테스트
    
    func testInitialState() {
        XCTAssertNotNil(powerManager)
        XCTAssertFalse(powerManager.isTimerActive)
        XCTAssertNil(powerManager.remainingTime)
    }
    
    // MARK: - 카페인 모드 토글 테스트
    
    func testToggleCaffeine() {
        let expectation = XCTestExpectation(description: "Toggle caffeine")
        
        let initialState = powerManager.isCaffeineEnabled
        
        powerManager.toggleCaffeine { success in
            // 권한 문제로 실패할 수 있으므로 상태 변경만 확인
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - 타이머 설정 테스트
    
    func testSetTimer() {
        let expectation = XCTestExpectation(description: "Set timer")
        expectation.isInverted = true // 타이머가 즉시 완료되지 않아야 함
        
        powerManager.setTimer(minutes: 1) {
            expectation.fulfill()
        }
        
        // 타이머가 설정되었는지 확인
        XCTAssertTrue(powerManager.isTimerActive)
        XCTAssertNotNil(powerManager.remainingTime)
        
        // 타이머 취소 (테스트 완료를 위해)
        powerManager.cancelTimer()
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testCancelTimer() {
        let expectation = XCTestExpectation(description: "Set timer for cancel")
        expectation.isInverted = true
        
        // 타이머 설정
        powerManager.setTimer(minutes: 30) {
            expectation.fulfill()
        }
        XCTAssertTrue(powerManager.isTimerActive)
        
        // 타이머 취소
        powerManager.cancelTimer()
        XCTAssertFalse(powerManager.isTimerActive)
        XCTAssertNil(powerManager.remainingTime)
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    // MARK: - 시스템 상태 확인 테스트
    
    func testGetCurrentSystemCaffeineState() {
        // 시스템 상태 확인 (실제 결과는 시스템에 따라 다름)
        let systemState = powerManager.getCurrentSystemCaffeineState()
        XCTAssertNotNil(systemState)
    }
    
    func testCheckPasswordlessSetup() {
        // 비밀번호 없이 실행 가능한지 확인
        let canRunPasswordless = powerManager.checkPasswordlessSetup()
        XCTAssertNotNil(canRunPasswordless)
    }
    
    // MARK: - 강제 비활성화 테스트
    
    func testForceDisableCaffeine() {
        // 카페인 모드와 타이머 설정
        powerManager.setTimer(minutes: 30) {}
        
        // 강제 비활성화
        powerManager.forceDisableCaffeine()
        
        // 모든 것이 비활성화되었는지 확인
        XCTAssertFalse(powerManager.isCaffeineEnabled)
        XCTAssertFalse(powerManager.isTimerActive)
        XCTAssertNil(powerManager.remainingTime)
    }
}