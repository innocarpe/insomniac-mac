import Foundation

class PowerManagerImpl: PowerManager {
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
        // Check actual system state first
        let systemState = getCurrentSystemCaffeineState()
        
        // Sync stored state with actual system state
        if systemState != isCaffeineEnabled {
            userDefaults.set(systemState, forKey: caffeineEnabledKey)
        }
        
        // Apply stored state if system state is off but stored state is on
        if !systemState && isCaffeineEnabled {
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
        return executePmsetCommand(disableSleep: true)
    }
    
    private func disableCaffeine() -> Bool {
        return executePmsetCommand(disableSleep: false)
    }
    
    func getCurrentSystemCaffeineState() -> Bool {
        let task = Process()
        task.launchPath = "/usr/bin/pmset"
        task.arguments = ["-g"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                // Look for "disablesleep 1" in the output
                // Using regex to match "disablesleep" followed by whitespace and "1"
                let pattern = "disablesleep\\s+1"
                if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                    let range = NSRange(location: 0, length: output.utf16.count)
                    return regex.firstMatch(in: output, options: [], range: range) != nil
                }
            }
        } catch {
            print("Error checking system caffeine state: \(error)")
        }
        
        return false
    }
    
    private func executePmsetCommand(disableSleep: Bool) -> Bool {
        let value = disableSleep ? "1" : "0"
        
        // First try with sudo (passwordless if configured)
        let task = Process()
        task.launchPath = "/usr/bin/sudo"
        task.arguments = ["-n", "pmset", "-a", "disablesleep", value]
        
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
        do shell script "pmset -a disablesleep \(value)" with administrator privileges
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
        // Validate minimum timer value
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
        // First, try to check if the lid is closed
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
                // Check if lid is closed (AppleClamshellState = Yes)
                if output.contains("\"AppleClamshellState\" = Yes") {
                    // Lid is closed, force immediate sleep
                    let sleepTask = Process()
                    sleepTask.launchPath = "/usr/bin/pmset"
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
    }
}