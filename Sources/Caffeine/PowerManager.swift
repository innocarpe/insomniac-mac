import Foundation

class PowerManager {
    private let userDefaults = UserDefaults.standard
    private let caffeineEnabledKey = "CaffeineEnabled"
    private var hasPasswordlessSetup: Bool {
        return userDefaults.bool(forKey: "PasswordlessSetupComplete")
    }
    
    private var timer: Timer?
    private var timerEndDate: Date?
    
    var isCaffeineEnabled: Bool {
        return userDefaults.bool(forKey: caffeineEnabledKey)
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
        if isCaffeineEnabled {
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
    
    private func enableCaffeine() -> Bool {
        return executePmsetCommand(disableSleep: true)
    }
    
    private func disableCaffeine() -> Bool {
        return executePmsetCommand(disableSleep: false)
    }
    
    private func executePmsetCommand(disableSleep: Bool) -> Bool {
        let value = disableSleep ? "1" : "0"
        
        // First try with sudo (passwordless if configured)
        let task = Process()
        task.launchPath = "/usr/bin/sudo"
        task.arguments = ["-n", "pmset", "-b", "disablesleep", value]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            if task.terminationStatus == 0 {
                // Success with passwordless sudo
                userDefaults.set(true, forKey: "PasswordlessSetupComplete")
                return true
            }
        } catch {
            // Fall through to AppleScript method
        }
        
        // Fall back to AppleScript method (will ask for password)
        let script = """
        do shell script "pmset -b disablesleep \(value)" with administrator privileges
        """
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            scriptObject.executeAndReturnError(&error)
            return error == nil
        }
        
        return false
    }
    
    func checkPasswordlessSetup() -> Bool {
        let task = Process()
        task.launchPath = "/usr/bin/sudo"
        task.arguments = ["-n", "pmset", "-g"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            return false
        }
    }
    
    func setTimer(minutes: Int, completion: @escaping () -> Void) {
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
        }
        cancelTimer()
    }
    
    deinit {
        cancelTimer()
    }
}