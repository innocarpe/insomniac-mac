import AppKit
import UserNotifications

class StatusBarController: NSObject, NSMenuDelegate {
    private var statusItem: NSStatusItem?
    private var powerManager: PowerManager
    private var menu: NSMenu
    private var updateTimer: Timer?
    private var menuUpdateTimer: Timer?
    private var timerStatusItem: NSMenuItem?
    
    override init() {
        self.powerManager = PowerManager()
        self.menu = NSMenu()
        super.init()
        self.menu.delegate = self
        setupStatusItem()
        setupMenu()
        updateIcon()
        startUpdateTimer()
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.action = #selector(toggleCaffeine)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    private func setupMenu() {
        // Timer status (if active)
        if powerManager.isTimerActive, let remaining = powerManager.remainingTime {
            timerStatusItem = NSMenuItem(title: formatRemainingTime(remaining), action: nil, keyEquivalent: "")
            timerStatusItem?.isEnabled = false
            menu.addItem(timerStatusItem!)
            menu.addItem(NSMenuItem.separator())
        }
        
        let toggleItem = NSMenuItem(
            title: powerManager.isCaffeineEnabled ? "카페인 모드 끄기" : "카페인 모드 켜기",
            action: #selector(toggleCaffeine),
            keyEquivalent: ""
        )
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        // Timer submenu (always visible)
        let timerItem = NSMenuItem(title: "카페인 타이머", action: nil, keyEquivalent: "")
        let timerSubmenu = NSMenu()
        
        // Timer options
        let timerOptions = [
            (30, "30분"),
            (60, "1시간"),
            (120, "2시간"),
            (180, "3시간"),
            (240, "4시간"),
            (300, "5시간"),
            (360, "6시간")
        ]
        
        for (minutes, title) in timerOptions {
            let item = NSMenuItem(title: title, action: #selector(setTimer(_:)), keyEquivalent: "")
            item.target = self
            item.tag = minutes
            timerSubmenu.addItem(item)
        }
        
        if powerManager.isTimerActive {
            timerSubmenu.addItem(NSMenuItem.separator())
            let cancelItem = NSMenuItem(title: "타이머 취소", action: #selector(cancelTimer), keyEquivalent: "")
            cancelItem.target = self
            timerSubmenu.addItem(cancelItem)
        }
        
        timerItem.submenu = timerSubmenu
        menu.addItem(timerItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let launchAtLoginItem = NSMenuItem(
            title: "시작 시 실행",
            action: #selector(toggleLaunchAtLogin),
            keyEquivalent: ""
        )
        launchAtLoginItem.target = self
        launchAtLoginItem.state = LaunchAtLogin.isEnabled ? .on : .off
        menu.addItem(launchAtLoginItem)
        
        let aboutItem = NSMenuItem(
            title: "정보",
            action: #selector(showAbout),
            keyEquivalent: ""
        )
        aboutItem.target = self
        menu.addItem(aboutItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(
            title: "종료",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
    }
    
    private func updateIcon() {
        guard let button = statusItem?.button else { return }
        
        let iconName = powerManager.isCaffeineEnabled ? "cup.and.saucer.fill" : "cup.and.saucer"
        
        if let image = NSImage(systemSymbolName: iconName, accessibilityDescription: "Caffeine") {
            image.isTemplate = true
            button.image = image
        } else {
            button.title = powerManager.isCaffeineEnabled ? "☕️" : "💤"
        }
        
        button.toolTip = powerManager.isCaffeineEnabled 
            ? "카페인 모드 ON - 클릭하여 끄기" 
            : "카페인 모드 OFF - 클릭하여 켜기"
    }
    
    private func updateMenu() {
        if let toggleItem = menu.items.first {
            toggleItem.title = powerManager.isCaffeineEnabled ? "카페인 모드 끄기" : "카페인 모드 켜기"
        }
        
        if menu.items.count > 2 {
            menu.items[2].state = LaunchAtLogin.isEnabled ? .on : .off
        }
    }
    
    @objc private func toggleCaffeine() {
        let event = NSApp.currentEvent
        
        if event?.type == .rightMouseUp {
            statusItem?.menu = menu
            statusItem?.button?.performClick(nil)
            statusItem?.menu = nil
        } else {
            powerManager.toggleCaffeine { [weak self] success in
                if success {
                    self?.updateIcon()
                    self?.rebuildMenu()
                } else {
                    self?.showError()
                }
            }
        }
    }
    
    @objc private func toggleLaunchAtLogin() {
        LaunchAtLogin.isEnabled.toggle()
        updateMenu()
    }
    
    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "Caffeine"
        alert.informativeText = """
        버전 1.0.0
        
        맥북을 닫아도 자동으로 잠들지 않도록 합니다.
        
        주요 기능:
        • 클릭 한 번으로 잠자기 방지 ON/OFF
        • 자동 꺼짐 타이머 (30분~6시간)
        • 시작 시 자동 실행 옵션
        • 비밀번호 없이 편리하게 사용
        
        개발: Caffeine for macOS
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "확인")
        alert.runModal()
    }
    
    @objc private func quit() {
        if powerManager.isCaffeineEnabled {
            powerManager.toggleCaffeine { _ in
                NSApplication.shared.terminate(nil)
            }
        } else {
            NSApplication.shared.terminate(nil)
        }
    }
    
    private func showError() {
        let alert = NSAlert()
        alert.messageText = "오류"
        alert.informativeText = "카페인 모드를 변경할 수 없습니다. 관리자 권한이 필요할 수 있습니다."
        alert.alertStyle = .critical
        alert.addButton(withTitle: "확인")
        alert.runModal()
    }
    
    @objc private func setTimer(_ sender: NSMenuItem) {
        let minutes = sender.tag
        let wasEnabled = powerManager.isCaffeineEnabled
        
        powerManager.setTimer(minutes: minutes) { [weak self] in
            DispatchQueue.main.async {
                self?.updateIcon()
                self?.rebuildMenu()
                
                // Show notification
                if #available(macOS 10.14, *) {
                    let content = UNMutableNotificationContent()
                    content.title = "Caffeine"
                    content.body = "카페인 모드가 종료되었습니다"
                    content.sound = .default
                    
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                    UNUserNotificationCenter.current().add(request)
                }
            }
        }
        
        // Update UI immediately if caffeine was just enabled
        if !wasEnabled {
            updateIcon()
        }
        rebuildMenu()
    }
    
    @objc private func cancelTimer() {
        powerManager.cancelTimer()
        rebuildMenu()
    }
    
    private func rebuildMenu() {
        menu.removeAllItems()
        setupMenu()
    }
    
    private func formatRemainingTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%d시간 %d분 %d초 후 꺼짐", hours, minutes, secs)
        } else if minutes > 0 {
            return String(format: "%d분 %d초 후 꺼짐", minutes, secs)
        } else {
            return String(format: "%d초 후 꺼짐", secs)
        }
    }
    
    private func startUpdateTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            if self?.powerManager.isTimerActive == true {
                self?.rebuildMenu()
            }
        }
    }
    
    private func startMenuUpdateTimer() {
        menuUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimerDisplay()
        }
        // Add timer to RunLoop with correct mode for menu updates
        if let timer = menuUpdateTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func stopMenuUpdateTimer() {
        menuUpdateTimer?.invalidate()
        menuUpdateTimer = nil
    }
    
    private func updateTimerDisplay() {
        guard let timerItem = timerStatusItem,
              let remaining = powerManager.remainingTime else { return }
        
        timerItem.title = formatRemainingTime(remaining)
    }
    
    // MARK: - NSMenuDelegate
    
    func menuWillOpen(_ menu: NSMenu) {
        startMenuUpdateTimer()
    }
    
    func menuDidClose(_ menu: NSMenu) {
        stopMenuUpdateTimer()
    }
    
    deinit {
        updateTimer?.invalidate()
        menuUpdateTimer?.invalidate()
    }
}