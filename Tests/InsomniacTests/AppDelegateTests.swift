import XCTest
import AppKit
@testable import Insomniac

final class AppDelegateTests: XCTestCase {
    var appDelegate: AppDelegate!
    var mockPowerManager: MockPowerManager!
    
    override func setUp() {
        super.setUp()
        mockPowerManager = MockPowerManager()
        appDelegate = AppDelegate(powerManager: mockPowerManager)
    }
    
    override func tearDown() {
        appDelegate = nil
        mockPowerManager = nil
        super.tearDown()
    }
    
    // MARK: - 초기화 테스트
    
    func testInitialization() {
        XCTAssertNotNil(appDelegate)
    }
    
    // MARK: - 앱 종료 시 카페인 비활성화 테스트
    
    func testApplicationWillTerminateWithCaffeineEnabled() {
        // 카페인 모드 활성화
        mockPowerManager.mockIsCaffeineEnabled = true
        
        // 앱 종료 시뮬레이션
        appDelegate.applicationWillTerminate(Notification(name: NSApplication.willTerminateNotification))
        
        // 강제 비활성화가 호출되었는지 확인
        XCTAssertEqual(mockPowerManager.forceDisableCaffeineCallCount, 1)
        XCTAssertFalse(mockPowerManager.mockIsCaffeineEnabled)
    }
    
    func testApplicationWillTerminateWithCaffeineDisabled() {
        // 카페인 모드 비활성화 상태
        mockPowerManager.mockIsCaffeineEnabled = false
        
        // 앱 종료 시뮬레이션
        appDelegate.applicationWillTerminate(Notification(name: NSApplication.willTerminateNotification))
        
        // 강제 비활성화가 호출되지 않아야 함
        XCTAssertEqual(mockPowerManager.forceDisableCaffeineCallCount, 0)
    }
    
    // MARK: - 시스템 종료 시 카페인 비활성화 테스트
    
    func testSystemWillPowerOffWithCaffeineEnabled() {
        // 카페인 모드 활성화
        mockPowerManager.mockIsCaffeineEnabled = true
        
        // 시스템 종료 알림 시뮬레이션
        appDelegate.performSelector(onMainThread: NSSelectorFromString("systemWillPowerOff:"), 
                                    with: Notification(name: NSWorkspace.willPowerOffNotification), 
                                    waitUntilDone: true)
        
        // 강제 비활성화가 호출되었는지 확인
        XCTAssertEqual(mockPowerManager.forceDisableCaffeineCallCount, 1)
        XCTAssertFalse(mockPowerManager.mockIsCaffeineEnabled)
    }
    
    // MARK: - 비밀번호 없이 실행 설정 테스트
    
    func testPasswordlessSetupCheck() {
        // 비밀번호 없이 실행 설정 확인
        mockPowerManager.checkPasswordlessSetupResult = true
        let result = mockPowerManager.checkPasswordlessSetup()
        XCTAssertTrue(result)
        XCTAssertEqual(mockPowerManager.checkPasswordlessSetupCallCount, 1)
    }
    
    // MARK: - 보안 상태 복원 테스트
    
    func testApplicationSupportsSecureRestorableState() {
        let supportsSecureState = appDelegate.applicationSupportsSecureRestorableState(NSApplication.shared)
        XCTAssertTrue(supportsSecureState)
    }
}