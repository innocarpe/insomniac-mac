import AppKit
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?
    private let powerManager: PowerManager
    
    init(powerManager: PowerManager? = nil) {
        self.powerManager = powerManager ?? PowerManagerImpl()
        super.init()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Request notification permission
        if #available(macOS 10.14, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        }
        
        // Register for system shutdown/restart notifications
        let workspace = NSWorkspace.shared
        workspace.notificationCenter.addObserver(self, 
                                               selector: #selector(systemWillPowerOff(_:)), 
                                               name: NSWorkspace.willPowerOffNotification, 
                                               object: nil)
        workspace.notificationCenter.addObserver(self, 
                                               selector: #selector(systemWillPowerOff(_:)), 
                                               name: NSWorkspace.sessionDidResignActiveNotification, 
                                               object: nil)
        
        // Check if passwordless setup is needed
        checkAndSetupPasswordless()
        
        statusBarController = StatusBarController(powerManager: powerManager)
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Always disable caffeine when app is quitting
        if powerManager.isCaffeineEnabled {
            powerManager.forceDisableCaffeine()
        }
    }
    
    @objc private func systemWillPowerOff(_ notification: Notification) {
        // Disable caffeine when system is shutting down or restarting
        if powerManager.isCaffeineEnabled {
            powerManager.forceDisableCaffeine()
        }
    }
    
    private func checkAndSetupPasswordless() {
        let userDefaults = UserDefaults.standard
        let setupKey = "PasswordlessSetupComplete"
        
        // If already marked as complete, just verify it works silently
        if userDefaults.bool(forKey: setupKey) {
            if verifyPasswordlessSetup() {
                return // Everything is working
            } else {
                // Reset flag, will show dialog below
                print("Passwordless setup verification failed, resetting flag")
                userDefaults.set(false, forKey: setupKey)
            }
        }
        
        // If not set up or verification failed, check if it actually works
        if verifyPasswordlessSetup() {
            // It works even though not marked, just mark it as complete
            userDefaults.set(true, forKey: setupKey)
            return
        }
        
        // Only show dialog if truly needed
        showPasswordlessSetupDialog()
    }
    
    private func verifyPasswordlessSetup() -> Bool {
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
    
    
    private func showPasswordlessSetupDialog() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Caffeine 초기 설정"
            alert.informativeText = """
            Caffeine을 사용하려면 시스템 권한이 필요합니다.
            
            지금 한 번만 관리자 비밀번호를 입력하면, 
            이후에는 비밀번호 없이 편리하게 사용할 수 있습니다.
            
            설정하시겠습니까?
            """
            alert.alertStyle = .informational
            alert.addButton(withTitle: "설정하기")
            alert.addButton(withTitle: "나중에")
            
            if alert.runModal() == .alertFirstButtonReturn {
                self.performPasswordlessSetup()
            }
        }
    }
    
    private func performPasswordlessSetup() {
        let script = """
        do shell script "echo '%admin ALL=(ALL) NOPASSWD: /usr/bin/pmset -a disablesleep 0, /usr/bin/pmset -a disablesleep 1, /usr/bin/pmset sleepnow' | sudo tee /etc/sudoers.d/caffeine && sudo chmod 0440 /etc/sudoers.d/caffeine && sudo chown root:wheel /etc/sudoers.d/caffeine" with administrator privileges
        """
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            scriptObject.executeAndReturnError(&error)
            
            if error == nil {
                // Verify the setup actually works
                Thread.sleep(forTimeInterval: 1.0)
                if verifyPasswordlessSetup() {
                    UserDefaults.standard.set(true, forKey: "PasswordlessSetupComplete")
                    
                    let successAlert = NSAlert()
                    successAlert.messageText = "설정 완료!"
                    successAlert.informativeText = "이제 Caffeine을 비밀번호 없이 사용할 수 있습니다."
                    successAlert.alertStyle = .informational
                    successAlert.addButton(withTitle: "시작하기")
                    successAlert.runModal()
                } else {
                    showSetupFailureAlert("설정이 완료되었지만 검증에 실패했습니다.")
                }
            } else {
                let errorMessage = error?["NSAppleScriptErrorMessage"] as? String ?? "알 수 없는 오류"
                showSetupFailureAlert("설정 중 오류가 발생했습니다: \(errorMessage)")
            }
        }
    }
    
    private func showSetupFailureAlert(_ message: String) {
        let errorAlert = NSAlert()
        errorAlert.messageText = "설정 실패"
        errorAlert.informativeText = "\(message)\n\n터미널에서 다음 명령을 실행하여 수동으로 설정할 수 있습니다:\n\necho '%admin ALL=(ALL) NOPASSWD: /usr/bin/pmset -a disablesleep 0, /usr/bin/pmset -a disablesleep 1, /usr/bin/pmset sleepnow' | sudo tee /etc/sudoers.d/caffeine && sudo chmod 0440 /etc/sudoers.d/caffeine"
        errorAlert.alertStyle = .warning
        errorAlert.addButton(withTitle: "확인")
        errorAlert.addButton(withTitle: "다시 시도")
        
        if errorAlert.runModal() == .alertSecondButtonReturn {
            performPasswordlessSetup()
        }
    }
}