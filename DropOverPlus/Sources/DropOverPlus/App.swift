import SwiftUI
import AppKit

// MARK: - App Entry Point

@main
struct DropOverPlusApp: App {
    /// Use AppKit delegate for menu bar and system-level features
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            EmptyView()
                .frame(width: 0, height: 0)
                .hidden()
        }
        .windowResizability(.contentSize)
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    let shelfManager = ShelfManager()
    private var statusItem: NSStatusItem!
    private var hotKeyManager: HotKeyManager!
    private var languageObserver: NSObjectProtocol?

    func applicationDidFinishLaunching(_ notification: Notification) {
        shelfManager.delegate = self
        hotKeyManager = HotKeyManager(shelfManager: shelfManager)
        hotKeyManager.registerHotKey()
        setupMenuBar()
        // 启动时自动创建一个新的 Shelf
        shelfManager.createShelf(withFiles: [])

        // 监听语言切换通知
        languageObserver = NotificationCenter.default.addObserver(
            forName: .languageDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.rebuildMenu()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        shelfManager.saveState()
        hotKeyManager.unregisterHotKey()
        if let obs = languageObserver {
            NotificationCenter.default.removeObserver(obs)
        }
    }

    // MARK: - Menu Bar

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(systemSymbolName: "tray.full", accessibilityDescription: L.appName)
        rebuildMenu()
    }

    private func rebuildMenu() {
        let menu = NSMenu()

        // New Shelf
        let newItem = NSMenuItem(title: L.newShelf, action: #selector(createNewShelf), keyEquivalent: "n")
        newItem.keyEquivalentModifierMask = [.command, .shift]
        menu.addItem(newItem)

        menu.addItem(NSMenuItem.separator())

        // Language submenu
        let langMenu = NSMenu()
        let enItem = NSMenuItem(title: "English", action: #selector(setLanguageEnglish), keyEquivalent: "")
        enItem.state = L.currentLang == "en" ? .on : .off
        enItem.target = self
        let zhItem = NSMenuItem(title: "简体中文", action: #selector(setLanguageChinese), keyEquivalent: "")
        zhItem.state = L.currentLang == "zh-Hans" ? .on : .off
        zhItem.target = self
        langMenu.addItem(enItem)
        langMenu.addItem(zhItem)

        let langItem = NSMenuItem(title: L.language, action: nil, keyEquivalent: "")
        langItem.submenu = langMenu
        menu.addItem(langItem)

        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(title: L.quit, action: #selector(NSApp.terminate), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    @objc private func setLanguageEnglish() {
        L.currentLang = "en"
    }

    @objc private func setLanguageChinese() {
        L.currentLang = "zh-Hans"
    }

    @objc private func createNewShelf() {
        shelfManager.createShelf(withFiles: [])
    }

    /// Called when files are dropped onto the status bar icon
    func handleFilesDropped(_ urls: [URL]) {
        shelfManager.createShelf(withFiles: urls)
    }
}

// MARK: - ShelfManager Delegate

extension AppDelegate: ShelfManagerDelegate {
    func shelfManagerDidUpdate() {
        // Nothing to update in menu bar
    }
}
