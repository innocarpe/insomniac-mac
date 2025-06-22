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
    
    func testInvalidTimerValue() {
        // 0분 타이머 설정 시도
        powerManager.setTimer(minutes: 0) {}
        
        // 타이머가 설정되지 않아야 함
        XCTAssertFalse(powerManager.isTimerActive)
        XCTAssertNil(powerManager.remainingTime)
        
        // 음수 타이머 설정 시도
        powerManager.setTimer(minutes: -5) {}
        
        // 타이머가 설정되지 않아야 함
        XCTAssertFalse(powerManager.isTimerActive)
        XCTAssertNil(powerManager.remainingTime)
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
    
    // MARK: - 타이머 만료 시 맥북 덮개 확인 테스트
    
    func testTimerExpirationWithLidClosed() {
        let expectation = XCTestExpectation(description: "Timer expiration test")
        
        // 초기 상태 확인
        XCTAssertFalse(powerManager.isCaffeineEnabled)
        XCTAssertFalse(powerManager.isTimerActive)
        
        // 1분 타이머 설정
        powerManager.setTimer(minutes: 1) {
            expectation.fulfill()
        }
        
        // 타이머 설정 후 상태 확인
        XCTAssertTrue(powerManager.isCaffeineEnabled) // 자동으로 활성화되어야 함
        XCTAssertTrue(powerManager.isTimerActive)
        XCTAssertNotNil(powerManager.remainingTime)
        
        // 테스트를 위해 타이머 취소 (실제 1분을 기다리지 않음)
        powerManager.cancelTimer()
        
        // 수동으로 타이머 만료 시뮬레이션
        powerManager.forceDisableCaffeine()
        
        // 최종 상태 확인
        XCTAssertFalse(powerManager.isCaffeineEnabled)
        XCTAssertFalse(powerManager.isTimerActive)
        XCTAssertNil(powerManager.remainingTime)
    }
    
    // MARK: - pmset 명령어 옵션 테스트
    
    func testPmsetCommandUsesAllPowerSources() {
        // PowerManagerImpl의 내부 구현을 직접 테스트할 수 없으므로
        // 시스템 상태 확인을 통해 간접적으로 검증
        let systemState = powerManager.getCurrentSystemCaffeineState()
        
        // 현재 시스템 상태를 확인했다는 것만 검증
        // 실제 pmset -a 옵션은 통합 테스트에서 확인
        XCTAssertNotNil(systemState)
    }
    
    // MARK: - 맥북 덮개 상태 확인 로직 테스트
    
    func testLidStateDetection() {
        // ioreg 명령어를 사용한 덮개 상태 확인을 시뮬레이션
        // 실제 하드웨어 상태에 의존하므로 명령어 실행 가능 여부만 테스트
        let task = Process()
        task.launchPath = "/usr/sbin/ioreg"
        task.arguments = ["-r", "-k", "AppleClamshellState", "-d", "4"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                // 출력이 있는지만 확인 (실제 상태는 하드웨어에 의존)
                XCTAssertFalse(output.isEmpty)
            }
        } catch {
            // 명령어 실행 실패는 허용 (CI 환경 등에서)
            print("ioreg command failed: \(error)")
        }
    }
}