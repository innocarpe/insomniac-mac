import Foundation
import ServiceManagement

struct LaunchAtLogin {
    private static let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.personal.caffeine"
    
    static var isEnabled: Bool {
        get {
            if #available(macOS 13.0, *) {
                return SMAppService.mainApp.status == .enabled
            } else {
                return UserDefaults.standard.bool(forKey: "LaunchAtLogin")
            }
        }
        set {
            if #available(macOS 13.0, *) {
                do {
                    if newValue {
                        try SMAppService.mainApp.register()
                    } else {
                        try SMAppService.mainApp.unregister()
                    }
                } catch {
                    print("Failed to \(newValue ? "enable" : "disable") launch at login: \(error)")
                }
            } else {
                let success = SMLoginItemSetEnabled(bundleIdentifier as CFString, newValue)
                if success {
                    UserDefaults.standard.set(newValue, forKey: "LaunchAtLogin")
                }
            }
        }
    }
}