import Foundation

/// 多语言字符串，支持简体中文和英文
/// 用法: L.newShelf, L.quit, L.dragCompleteTitle, etc.
struct L {
    private static var bundle: Bundle {
        let lang = Locale.preferredLanguages.first ?? "en"
        let res = lang.hasPrefix("zh") ? "zh-Hans" : "en"
        if let path = Bundle.main.path(forResource: res, ofType: "lproj"),
           let b = Bundle(path: path) { return b }
        return Bundle.main
    }

    private static func str(_ key: String) -> String {
        bundle.localizedString(forKey: key, value: nil, table: nil)
    }

    // MARK: - App
    static let appName    = str("app.name")
    static let appTagline = str("app.tagline")

    // MARK: - Menu
    static let newShelf = str("menu.newShelf")
    static let quit     = str("menu.quit")

    // MARK: - Shelf
    static func shelfTitle(_ id: String) -> String {
        String(format: str("shelf.defaultTitle"), id)
    }
    static func fileCount(_ n: Int) -> String {
        String(format: str("shelf.files"), n)
    }
    static func created(_ s: String) -> String {
        String(format: str("shelf.created"), s)
    }
    static func totalSize(_ s: String) -> String {
        String(format: str("shelf.totalSize"), s)
    }
    static let empty      = str("shelf.empty")
    static let clearShelf = str("shelf.clearShelf")
    static let addFiles   = str("shelf.addFiles")
    static let selectFiles = str("shelf.selectFiles")
    static let dragHint   = str("shelf.dragHint")

    // MARK: - Drag
    static let dragCompleteTitle   = str("drag.complete.title")
    static func dragCompleteSingle(_ name: String) -> String {
        String(format: str("drag.complete.single"), name)
    }
    static func dragCompleteMulti(_ count: Int) -> String {
        String(format: str("drag.complete.multi"), count)
    }
    static let dragMove = str("drag.move")
    static let dragKeep = str("drag.keep")

    // MARK: - Context Menu
    static let ctxOpen         = str("context.open")
    static let ctxShowInFinder = str("context.showInFinder")
    static let ctxQuickLook    = str("context.quickLook")
    static let ctxCopy         = str("context.copy")
    static let ctxRemove       = str("context.remove")

    // MARK: - Settings
    static let settingsTitle   = str("settings.title")
    static let settingsGeneral = str("settings.general")
    static let settingsAbout   = str("settings.about")
    static let closeAfterDrag  = str("settings.closeAfterDrag")
    static let floatOnTop      = str("settings.floatOnTop")
    static func maxRecent(_ n: Int) -> String {
        String(format: str("settings.maxRecent"), n)
    }
    static let shortcuts   = str("settings.shortcuts")
    static let newShelfKey = str("settings.newShelf")
    static func version(_ v: String, _ t: String) -> String {
        String(format: str("settings.version"), v, t)
    }
    static let aboutDesc = str("settings.about.desc")

    // MARK: - HotKey
    static let hotkeyOK     = str("hotkey.registered")
    static let hotkeyFailed = str("hotkey.failed")

    // MARK: - Errors
    static func saveFailed(_ e: String) -> String {
        String(format: str("error.saveFailed"), e)
    }
    static func loadFailed(_ e: String) -> String {
        String(format: str("error.loadFailed"), e)
    }
    static let quickLookFailed = str("error.quickLookFailed")
}
