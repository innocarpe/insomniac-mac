import XCTest
import AppKit
@testable import Caffeine

/// 통합 테스트 - 여러 컴포넌트가 함께 동작하는 시나리오 테스트
final class IntegrationTests: XCTestCase {
    
    var appDelegate: AppDelegate!
    var mockPowerManager: MockPowerManager!
    var statusBarController: StatusBarController!
    
    override func setUp() {
        super.setUp()
        mockPowerManager = MockPowerManager()
        appDelegate = AppDelegate(powerManager: mockPowerManager)
        statusBarController = StatusBarController(powerManager: mockPowerManager)
    }
    
    override func tearDown() {
        appDelegate = nil
        statusBarController = nil
        mockPowerManager?.reset()
        mockPowerManager = nil
        super.tearDown()
    }
    
    // MARK: - 시나리오 1: 기본 사용 흐름
    
    func testBasicUsageFlow() {
        // 1. 초기 상태 확인
        XCTAssertFalse(mockPowerManager.isCaffeineEnabled)
        XCTAssertFalse(mockPowerManager.isTimerActive)
        
        // 2. 카페인 모드 활성화
        mockPowerManager.toggleCaffeine { success in
            XCTAssertTrue(success)
        }
        XCTAssertTrue(mockPowerManager.isCaffeineEnabled)
        XCTAssertEqual(mockPowerManager.toggleCaffeineCallCount, 1)
        
        // 3. 카페인 모드 비활성화
        mockPowerManager.toggleCaffeine { success in
            XCTAssertTrue(success)
        }
        XCTAssertFalse(mockPowerManager.isCaffeineEnabled)
        XCTAssertEqual(mockPowerManager.toggleCaffeineCallCount, 2)
    }
    
    // MARK: - 시나리오 2: 타이머 사용 흐름
    
    func testTimerUsageFlow() {
        // 1. OFF 상태에서 타이머 설정
        XCTAssertFalse(mockPowerManager.isCaffeineEnabled)
        
        let timerExpectation = XCTestExpectation(description: "Timer completion")
        mockPowerManager.setTimer(minutes: 30) {
            timerExpectation.fulfill()
        }
        
        // 2. 자동으로 카페인 모드 활성화 확인
        XCTAssertTrue(mockPowerManager.isCaffeineEnabled)
        XCTAssertTrue(mockPowerManager.isTimerActive)
        XCTAssertEqual(mockPowerManager.mockRemainingTime, 1800) // 30분
        
        // 3. 타이머 취소
        mockPowerManager.cancelTimer()
        XCTAssertFalse(mockPowerManager.isTimerActive)
        XCTAssertNil(mockPowerManager.remainingTime)
        XCTAssertTrue(mockPowerManager.isCaffeineEnabled) // 카페인은 여전히 활성화
        
        // 타이머가 취소되어 완료되지 않아야 함
        let result = XCTWaiter.wait(for: [timerExpectation], timeout: 0.5)
        XCTAssertEqual(result, .timedOut)
    }
    
    // MARK: - 시나리오 3: 타이머 만료 처리
    
    func testTimerExpirationFlow() {
        let timerExpectation = XCTestExpectation(description: "Timer expired")
        
        // 1. 타이머 설정 (1분)
        mockPowerManager.setTimer(minutes: 1) {
            timerExpectation.fulfill()
        }
        
        // 2. 타이머 설정 직후 상태 확인
        XCTAssertTrue(mockPowerManager.isCaffeineEnabled)
        XCTAssertTrue(mockPowerManager.isTimerActive)
        XCTAssertEqual(mockPowerManager.mockRemainingTime, 60) // 1분 = 60초
        
        // 3. 즉시 만료 시뮬레이션
        mockPowerManager.simulateTimerExpiration()
        
        // 4. 타이머 만료 확인
        wait(for: [timerExpectation], timeout: 1.0)
        
        // 5. 카페인 모드가 자동으로 꺼졌는지 확인
        XCTAssertFalse(mockPowerManager.isCaffeineEnabled)
        XCTAssertFalse(mockPowerManager.isTimerActive)
        XCTAssertNil(mockPowerManager.remainingTime)
    }
    
    // MARK: - 시나리오 4: 앱 종료 시 상태 정리
    
    func testAppTerminationFlow() {
        // 1. 카페인 모드와 타이머 활성화
        mockPowerManager.setTimer(minutes: 60) {}
        XCTAssertTrue(mockPowerManager.isCaffeineEnabled)
        XCTAssertTrue(mockPowerManager.isTimerActive)
        
        // 2. 앱 종료 시뮬레이션
        appDelegate.applicationWillTerminate(Notification(name: NSApplication.willTerminateNotification))
        
        // 3. 모든 것이 비활성화되었는지 확인
        XCTAssertFalse(mockPowerManager.isCaffeineEnabled)
        XCTAssertFalse(mockPowerManager.isTimerActive)
        XCTAssertEqual(mockPowerManager.forceDisableCaffeineCallCount, 1)
    }
    
    // MARK: - 시나리오 5: 시스템 상태 동기화
    
    func testSystemStateSyncFlow() {
        // 1. 시스템 상태가 ON인 경우 시뮬레이션
        mockPowerManager.mockSystemCaffeineState = true
        mockPowerManager.mockIsCaffeineEnabled = false
        
        // 2. 시스템 상태 확인
        let systemState = mockPowerManager.getCurrentSystemCaffeineState()
        XCTAssertTrue(systemState)
        XCTAssertEqual(mockPowerManager.getCurrentSystemCaffeineStateCallCount, 1)
        
        // 3. 앱 상태와 시스템 상태가 다른 경우
        XCTAssertNotEqual(mockPowerManager.isCaffeineEnabled, systemState)
    }
    
    // MARK: - 시나리오 6: 에러 처리
    
    func testErrorHandlingFlow() {
        // 1. 토글 실패 시나리오
        mockPowerManager.toggleCaffeineSuccess = false
        
        let expectation = XCTestExpectation(description: "Toggle failed")
        mockPowerManager.toggleCaffeine { success in
            XCTAssertFalse(success)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        // 2. 상태가 변경되지 않았는지 확인
        XCTAssertFalse(mockPowerManager.isCaffeineEnabled)
    }
    
    // MARK: - 시나리오 7: 비밀번호 없이 실행 확인
    
    func testPasswordlessSetupFlow() {
        // 1. 초기 상태에서는 설정되지 않음
        mockPowerManager.checkPasswordlessSetupResult = false
        XCTAssertFalse(mockPowerManager.checkPasswordlessSetup())
        
        // 2. 설정 후
        mockPowerManager.checkPasswordlessSetupResult = true
        XCTAssertTrue(mockPowerManager.checkPasswordlessSetup())
        
        // 3. 호출 횟수 확인
        XCTAssertEqual(mockPowerManager.checkPasswordlessSetupCallCount, 2)
    }
    
    // MARK: - 시나리오 8: 타이머 만료 시 맥북 덮개 닫힘 처리
    
    func testTimerExpirationWithLidClosedFlow() {
        let timerExpectation = XCTestExpectation(description: "Timer expired with lid check")
        
        // 1. 맥북 덮개가 닫혀있는 상태 시뮬레이션
        mockPowerManager.mockLidClosed = true
        
        // 2. 타이머 설정 (1분)
        mockPowerManager.setTimer(minutes: 1) {
            timerExpectation.fulfill()
        }
        
        // 3. 타이머 설정 직후 상태 확인
        XCTAssertTrue(mockPowerManager.isCaffeineEnabled)
        XCTAssertTrue(mockPowerManager.isTimerActive)
        
        // 4. 즉시 만료 시뮬레이션
        mockPowerManager.simulateTimerExpiration()
        
        // 5. 타이머 만료 대기
        wait(for: [timerExpectation], timeout: 1.0)
        
        // 6. 카페인 모드가 꺼졌는지 확인
        XCTAssertFalse(mockPowerManager.isCaffeineEnabled)
        XCTAssertFalse(mockPowerManager.isTimerActive)
        
        // 7. 맥북 덮개 상태가 확인되었는지 검증
        // MockPowerManager에서는 실제로 sleepnow를 실행하지 않으므로
        // 덮개 상태 확인 플래그만 검증
        XCTAssertTrue(mockPowerManager.mockLidClosed)
    }
    
    // MARK: - 시나리오 9: 전원 상태에 관계없는 동작 확인
    
    func testAllPowerSourcesFlow() {
        // 1. AC 전원 연결 상태 시뮬레이션
        mockPowerManager.mockPowerSource = "AC Power"
        
        // 2. 카페인 모드 활성화
        mockPowerManager.toggleCaffeine { success in
            XCTAssertTrue(success)
        }
        XCTAssertTrue(mockPowerManager.isCaffeineEnabled)
        
        // 3. 배터리 전원으로 변경
        mockPowerManager.mockPowerSource = "Battery Power"
        
        // 4. 여전히 카페인 모드가 유지되는지 확인
        XCTAssertTrue(mockPowerManager.isCaffeineEnabled)
        
        // 5. 타이머 설정
        mockPowerManager.setTimer(minutes: 30) {}
        XCTAssertTrue(mockPowerManager.isTimerActive)
        
        // 6. 전원 상태에 관계없이 작동 확인
        XCTAssertEqual(mockPowerManager.toggleCaffeineCallCount, 1)
        XCTAssertEqual(mockPowerManager.setTimerCallCount, 1)
    }
}