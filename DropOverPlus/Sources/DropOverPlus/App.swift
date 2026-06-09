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

    func applicationDidFinishLaunching(_ notification: Notification) {
        shelfManager.delegate = self
        hotKeyManager = HotKeyManager(shelfManager: shelfManager)
        hotKeyManager.registerHotKey()
        setupMenuBar()
        // 启动时自动创建一个新的 Shelf
        shelfManager.createShelf(withFiles: [])
    }

    func applicationWillTerminate(_ notification: Notification) {
        shelfManager.saveState()
        hotKeyManager.unregisterHotKey()
    }

    // MARK: - Menu Bar

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(systemSymbolName: "tray.full", accessibilityDescription: L.appName)

        let menu = NSMenu()
        menu.delegate = self

        // New Shelf
        let newItem = NSMenuItem(title: L.newShelf, action: #selector(createNewShelf), keyEquivalent: "n")
        newItem.keyEquivalentModifierMask = [.command, .shift]
        menu.addItem(newItem)

        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(title: L.quit, action: #selector(NSApp.terminate), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    @objc private func createNewShelf() {
        shelfManager.createShelf(withFiles: [])
    }

    /// Called when files are dropped onto the status bar icon
    func handleFilesDropped(_ urls: [URL]) {
        shelfManager.createShelf(withFiles: urls)
    }


}

// MARK: - NSMenuDelegate

// MARK: - NSMenuDelegate

extension AppDelegate: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        // Nothing to update
    }
}

// MARK: - ShelfManager Delegate

extension AppDelegate: ShelfManagerDelegate {
    func shelfManagerDidUpdate() {
        // Nothing to update in menu bar
    }
}
