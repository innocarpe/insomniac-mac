import Foundation
import IOKit.pwr_mgt

class PowerManagerImpl: PowerManager {
    private let userDefaults = UserDefaults.standard
    private let caffeineEnabledKey = "CaffeineEnabled"

    private var assertionID: IOPMAssertionID = 0
    private var hasAssertion = false

    private var timer: Timer?
    private var timerEndDate: Date?

    var isCaffeineEnabled: Bool {
        return hasAssertion
    }

    var isTimerActive: Bool {
        return timer != nil && timerEndDate != nil
    }

    var remainingTime: TimeInterval? {
        guard let endDate = timerEndDate else { return nil }
        let remaining = endDate.timeIntervalSinceNow
        return remaining > 0 ? remaining : nil
    }

    init() {
        // Restore previous state if the app was restarted while caffeine was enabled
        if userDefaults.bool(forKey: caffeineEnabledKey) {
            _ = enableCaffeine()
        }
    }

    func toggleCaffeine(completion: @escaping (Bool) -> Void) {
        if isCaffeineEnabled {
            let success = disableCaffeine()
            if success {
                userDefaults.set(false, forKey: caffeineEnabledKey)
            }
            completion(success)
        } else {
            let success = enableCaffeine()
            if success {
                userDefaults.set(true, forKey: caffeineEnabledKey)
            }
            completion(success)
        }
    }

    func forceDisableCaffeine() {
        _ = disableCaffeine()
        userDefaults.set(false, forKey: caffeineEnabledKey)
        cancelTimer()
    }

    private func enableCaffeine() -> Bool {
        guard !hasAssertion else { return true }

        let reason = "Caffeine: 잠자기 방지 활성화" as CFString
        let status = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventSystemSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &assertionID
        )

        if status == kIOReturnSuccess {
            hasAssertion = true
            return true
        } else {
            print("IOPMAssertion 생성 실패: \(status)")
            return false
        }
    }

    private func disableCaffeine() -> Bool {
        guard hasAssertion else { return true }

        let status = IOPMAssertionRelease(assertionID)
        if status == kIOReturnSuccess {
            hasAssertion = false
            assertionID = 0
            return true
        } else {
            print("IOPMAssertion 해제 실패: \(status)")
            return false
        }
    }

    func getCurrentSystemCaffeineState() -> Bool {
        return hasAssertion
    }

    func checkPasswordlessSetup() -> Bool {
        // IOPMAssertion은 sudo 권한이 필요 없으므로 항상 true
        return true
    }

    func setTimer(minutes: Int, completion: @escaping () -> Void) {
        guard minutes > 0 else {
            print("Invalid timer value: \(minutes) minutes. Timer must be at least 1 minute.")
            return
        }

        // Cancel existing timer
        cancelTimer()

        // Enable caffeine if it's not already enabled
        if !isCaffeineEnabled {
            let success = enableCaffeine()
            if success {
                userDefaults.set(true, forKey: caffeineEnabledKey)
            }
        }

        // Set end date
        timerEndDate = Date().addingTimeInterval(TimeInterval(minutes * 60))

        // Create timer
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(minutes * 60), repeats: false) { [weak self] _ in
            self?.timerExpired()
            completion()
        }
    }

    func cancelTimer() {
        timer?.invalidate()
        timer = nil
        timerEndDate = nil
    }

    private func timerExpired() {
        if isCaffeineEnabled {
            _ = disableCaffeine()
            userDefaults.set(false, forKey: caffeineEnabledKey)

            // Force immediate sleep if lid is closed
            forceImmediateSleep()
        }
        cancelTimer()
    }

    private func forceImmediateSleep() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/ioreg")
        task.arguments = ["-r", "-k", "AppleClamshellState", "-d", "4"]

        let pipe = Pipe()
        task.standardOutput = pipe

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                if output.contains("\"AppleClamshellState\" = Yes") {
                    let sleepTask = Process()
                    sleepTask.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
                    sleepTask.arguments = ["sleepnow"]

                    try sleepTask.run()
                    sleepTask.waitUntilExit()
                }
            }
        } catch {
            print("Error checking lid state or forcing sleep: \(error)")
        }
    }

    deinit {
        cancelTimer()
        if hasAssertion {
            IOPMAssertionRelease(assertionID)
        }
    }
}
