import Foundation

/// PowerManager 프로토콜 - 전원 관리 기능의 인터페이스 정의
protocol PowerManager {
    /// 카페인 모드 활성화 여부
    var isCaffeineEnabled: Bool { get }
    
    /// 타이머 활성화 여부
    var isTimerActive: Bool { get }
    
    /// 남은 시간 (초 단위)
    var remainingTime: TimeInterval? { get }
    
    /// 카페인 모드 토글
    func toggleCaffeine(completion: @escaping (Bool) -> Void)
    
    /// 카페인 모드 강제 비활성화
    func forceDisableCaffeine()
    
    /// 타이머 설정
    func setTimer(minutes: Int, completion: @escaping () -> Void)
    
    /// 타이머 취소
    func cancelTimer()
    
    /// 비밀번호 없이 실행 가능한지 확인
    func checkPasswordlessSetup() -> Bool
    
    /// 현재 시스템의 카페인 상태 확인
    func getCurrentSystemCaffeineState() -> Bool
}