import Foundation

/// 多语言字符串，支持简体中文和英文
/// 用户可在菜单中切换语言，设置存储在 UserDefaults
/// 用法: L.newShelf, L.quit, L.dragCompleteTitle, etc.
struct L {
    private static let langKey = "DropOverPlusLanguage"

    /// 当前语言: "en" 或 "zh-Hans"
    static var currentLang: String {
        get {
            UserDefaults.standard.string(forKey: langKey)
                ?? (Locale.preferredLanguages.first?.hasPrefix("zh") == true ? "zh-Hans" : "en")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: langKey)
            NotificationCenter.default.post(name: .languageDidChange, object: nil)
        }
    }

    private static var bundle: Bundle {
        let name = currentLang == "zh-Hans" ? "zh-Hans" : "en"
        return Bundle(path: Bundle.main.path(forResource: name, ofType: "lproj") ?? "") ?? Bundle.main
    }

    private static func str(_ key: String) -> String {
        bundle.localizedString(forKey: key, value: nil, table: nil)
    }

    // MARK: - App
    static var appName: String { str("app.name") }
    static var appTagline: String { str("app.tagline") }

    // MARK: - Menu
    static var newShelf: String { str("menu.newShelf") }
    static var quit: String { str("menu.quit") }
    static var language: String { str("menu.language") }

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
    static var empty: String { str("shelf.empty") }
    static var clearShelf: String { str("shelf.clearShelf") }
    static var addFiles: String { str("shelf.addFiles") }
    static var selectFiles: String { str("shelf.selectFiles") }
    static var dragHint: String { str("shelf.dragHint") }

    // MARK: - Drag
    static var dragCompleteTitle: String { str("drag.complete.title") }
    static func dragCompleteSingle(_ name: String) -> String {
        String(format: str("drag.complete.single"), name)
    }
    static func dragCompleteMulti(_ count: Int) -> String {
        String(format: str("drag.complete.multi"), count)
    }
    static var dragMove: String { str("drag.move") }
    static var dragKeep: String { str("drag.keep") }

    // MARK: - Context Menu
    static var ctxOpen: String { str("context.open") }
    static var ctxShowInFinder: String { str("context.showInFinder") }
    static var ctxQuickLook: String { str("context.quickLook") }
    static var ctxCopy: String { str("context.copy") }
    static var ctxRemove: String { str("context.remove") }

    // MARK: - Settings
    static var settingsTitle: String { str("settings.title") }
    static var settingsGeneral: String { str("settings.general") }
    static var settingsAbout: String { str("settings.about") }
    static var closeAfterDrag: String { str("settings.closeAfterDrag") }
    static var floatOnTop: String { str("settings.floatOnTop") }
    static func maxRecent(_ n: Int) -> String {
        String(format: str("settings.maxRecent"), n)
    }
    static var shortcuts: String { str("settings.shortcuts") }
    static var newShelfKey: String { str("settings.newShelf") }
    static func version(_ v: String, _ t: String) -> String {
        String(format: str("settings.version"), v, t)
    }
    static var aboutDesc: String { str("settings.about.desc") }

    // MARK: - HotKey
    static var hotkeyOK: String { str("hotkey.registered") }
    static var hotkeyFailed: String { str("hotkey.failed") }

    // MARK: - Errors
    static func saveFailed(_ e: String) -> String {
        String(format: str("error.saveFailed"), e)
    }
    static func loadFailed(_ e: String) -> String {
        String(format: str("error.loadFailed"), e)
    }
    static var quickLookFailed: String { str("error.quickLookFailed") }
}

extension Notification.Name {
    static let languageDidChange = Notification.Name("DropOverPlusLanguageDidChange")
}
