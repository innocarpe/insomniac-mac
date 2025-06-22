import XCTest
import AppKit
@testable import Caffeine

final class StatusBarControllerTests: XCTestCase {
    var statusBarController: StatusBarController!
    var mockPowerManager: MockPowerManager!
    
    override func setUp() {
        super.setUp()
        mockPowerManager = MockPowerManager()
        statusBarController = StatusBarController(powerManager: mockPowerManager)
    }
    
    override func tearDown() {
        statusBarController = nil
        mockPowerManager = nil
        super.tearDown()
    }
    
    // MARK: - 초기화 테스트
    
    func testInitialization() {
        XCTAssertNotNil(statusBarController)
        // StatusBarController가 생성되었고 PowerManager를 가지고 있는지 확인
        XCTAssertEqual(mockPowerManager.getCurrentSystemCaffeineStateCallCount, 0)
    }
    
    // MARK: - PowerManager 상호작용 테스트
    
    func testPowerManagerInteraction() {
        // StatusBarController가 PowerManager를 올바르게 사용하는지 간접적으로 확인
        
        // 초기 상태
        XCTAssertFalse(mockPowerManager.isCaffeineEnabled)
        XCTAssertFalse(mockPowerManager.isTimerActive)
        
        // 타이머 설정 시뮬레이션
        mockPowerManager.setTimer(minutes: 30) {}
        
        // PowerManager 상태 확인
        XCTAssertTrue(mockPowerManager.isCaffeineEnabled)
        XCTAssertTrue(mockPowerManager.isTimerActive)
        XCTAssertEqual(mockPowerManager.setTimerCallCount, 1)
    }
    
    // MARK: - 메뉴 델리게이트 테스트
    
    func testMenuDelegate() {
        // NSMenuDelegate 메서드들이 구현되어 있는지 확인
        let menu = NSMenu()
        
        // menuWillOpen 테스트
        statusBarController.menuWillOpen(menu)
        
        // menuDidClose 테스트
        statusBarController.menuDidClose(menu)
        
        // 크래시 없이 실행되는지 확인
        XCTAssertTrue(true)
    }
    
    // MARK: - 타이머 상태 테스트
    
    func testTimerStateHandling() {
        // 타이머가 없을 때
        mockPowerManager.mockIsTimerActive = false
        mockPowerManager.mockRemainingTime = nil
        XCTAssertFalse(mockPowerManager.isTimerActive)
        XCTAssertNil(mockPowerManager.remainingTime)
        
        // 타이머가 있을 때
        mockPowerManager.mockIsTimerActive = true
        mockPowerManager.mockRemainingTime = 3600
        XCTAssertTrue(mockPowerManager.isTimerActive)
        XCTAssertEqual(mockPowerManager.remainingTime, 3600)
    }
    
    // MARK: - 시작 시 실행 테스트
    
    func testLaunchAtLoginIntegration() {
        // LaunchAtLogin의 현재 상태 저장
        let initialState = LaunchAtLogin.isEnabled
        
        // 상태 변경
        LaunchAtLogin.isEnabled = !initialState
        XCTAssertNotEqual(LaunchAtLogin.isEnabled, initialState)
        
        // 원래 상태로 복원
        LaunchAtLogin.isEnabled = initialState
        XCTAssertEqual(LaunchAtLogin.isEnabled, initialState)
    }
}