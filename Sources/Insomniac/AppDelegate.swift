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
        // Request notification permission (requires valid bundle identifier)
        if #available(macOS 10.14, *), Bundle.main.bundleIdentifier != nil {
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

        statusBarController = StatusBarController(powerManager: powerManager)
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        if powerManager.isCaffeineEnabled {
            powerManager.forceDisableCaffeine()
        }
    }

    @objc private func systemWillPowerOff(_ notification: Notification) {
        if powerManager.isCaffeineEnabled {
            powerManager.forceDisableCaffeine()
        }
    }
}
