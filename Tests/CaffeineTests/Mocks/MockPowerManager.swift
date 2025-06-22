import Foundation
@testable import Caffeine

/// PowerManager의 Mock 구현체 - 테스트용
class MockPowerManager: PowerManager {
    // 상태 추적
    var mockIsCaffeineEnabled = false
    var mockIsTimerActive = false
    var mockRemainingTime: TimeInterval?
    var mockSystemCaffeineState = false
    
    // 메서드 호출 추적
    var toggleCaffeineCallCount = 0
    var forceDisableCaffeineCallCount = 0
    var setTimerCallCount = 0
    var cancelTimerCallCount = 0
    var checkPasswordlessSetupCallCount = 0
    var getCurrentSystemCaffeineStateCallCount = 0
    
    // 메서드 동작 제어
    var toggleCaffeineSuccess = true
    var checkPasswordlessSetupResult = true
    var timerCompletionHandler: (() -> Void)?
    
    // MARK: - PowerManager Protocol Implementation
    
    var isCaffeineEnabled: Bool {
        return mockIsCaffeineEnabled
    }
    
    var isTimerActive: Bool {
        return mockIsTimerActive
    }
    
    var remainingTime: TimeInterval? {
        return mockRemainingTime
    }
    
    func toggleCaffeine(completion: @escaping (Bool) -> Void) {
        toggleCaffeineCallCount += 1
        
        if toggleCaffeineSuccess {
            mockIsCaffeineEnabled.toggle()
        }
        
        completion(toggleCaffeineSuccess)
    }
    
    func forceDisableCaffeine() {
        forceDisableCaffeineCallCount += 1
        mockIsCaffeineEnabled = false
        mockIsTimerActive = false
        mockRemainingTime = nil
    }
    
    func setTimer(minutes: Int, completion: @escaping () -> Void) {
        setTimerCallCount += 1
        
        // 타이머 설정 시 자동으로 카페인 모드 활성화
        if !mockIsCaffeineEnabled {
            mockIsCaffeineEnabled = true
        }
        
        mockIsTimerActive = true
        mockRemainingTime = TimeInterval(minutes * 60)
        timerCompletionHandler = completion
        
        // 테스트를 위해 즉시 타이머 만료 시뮬레이션 가능
        if minutes == 0 {
            simulateTimerExpiration()
        }
    }
    
    func cancelTimer() {
        cancelTimerCallCount += 1
        mockIsTimerActive = false
        mockRemainingTime = nil
        timerCompletionHandler = nil
    }
    
    func checkPasswordlessSetup() -> Bool {
        checkPasswordlessSetupCallCount += 1
        return checkPasswordlessSetupResult
    }
    
    func getCurrentSystemCaffeineState() -> Bool {
        getCurrentSystemCaffeineStateCallCount += 1
        return mockSystemCaffeineState
    }
    
    // MARK: - Test Helper Methods
    
    /// 타이머 만료 시뮬레이션
    func simulateTimerExpiration() {
        mockIsTimerActive = false
        mockRemainingTime = nil
        mockIsCaffeineEnabled = false
        timerCompletionHandler?()
        timerCompletionHandler = nil
    }
    
    /// 남은 시간 업데이트 시뮬레이션
    func updateRemainingTime(_ seconds: TimeInterval) {
        if mockIsTimerActive {
            mockRemainingTime = seconds
        }
    }
    
    /// 모든 상태 초기화
    func reset() {
        mockIsCaffeineEnabled = false
        mockIsTimerActive = false
        mockRemainingTime = nil
        mockSystemCaffeineState = false
        
        toggleCaffeineCallCount = 0
        forceDisableCaffeineCallCount = 0
        setTimerCallCount = 0
        cancelTimerCallCount = 0
        checkPasswordlessSetupCallCount = 0
        getCurrentSystemCaffeineStateCallCount = 0
        
        toggleCaffeineSuccess = true
        checkPasswordlessSetupResult = true
        timerCompletionHandler = nil
    }
}