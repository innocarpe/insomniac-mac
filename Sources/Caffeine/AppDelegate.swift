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
        
        // Check if already setup
        if userDefaults.bool(forKey: setupKey) {
            return
        }
        
        // Check if passwordless sudo already works
        let task = Process()
        task.launchPath = "/usr/bin/sudo"
        task.arguments = ["-n", "pmset", "-g"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            if task.terminationStatus == 0 {
                // Already works, mark as complete
                userDefaults.set(true, forKey: setupKey)
                return
            }
        } catch {
            // Continue to setup
        }
        
        // Show setup dialog
        showPasswordlessSetupDialog()
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
        do shell script "echo '%admin ALL=(ALL) NOPASSWD: /usr/bin/pmset -b disablesleep 0, /usr/bin/pmset -b disablesleep 1' | sudo tee /etc/sudoers.d/caffeine && sudo chmod 0440 /etc/sudoers.d/caffeine" with administrator privileges
        """
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            scriptObject.executeAndReturnError(&error)
            
            if error == nil {
                UserDefaults.standard.set(true, forKey: "PasswordlessSetupComplete")
                
                let successAlert = NSAlert()
                successAlert.messageText = "설정 완료!"
                successAlert.informativeText = "이제 Caffeine을 비밀번호 없이 사용할 수 있습니다."
                successAlert.alertStyle = .informational
                successAlert.addButton(withTitle: "시작하기")
                successAlert.runModal()
            } else {
                let errorAlert = NSAlert()
                errorAlert.messageText = "설정 실패"
                errorAlert.informativeText = "설정 중 오류가 발생했습니다. 나중에 다시 시도해주세요."
                errorAlert.alertStyle = .warning
                errorAlert.addButton(withTitle: "확인")
                errorAlert.runModal()
            }
        }
    }
}