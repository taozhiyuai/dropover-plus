import AppKit
import Quartz

// MARK: - QuickLook Service

/// Integrates macOS Quick Look preview for shelf files.
/// Uses QLPreviewPanel to show file previews.
struct QuickLookService {
    /// Show Quick Look preview starting from a specific index
    static func preview(urls: [URL], at index: Int) {
        guard index >= 0, index < urls.count else { return }
        let controller = QuickLookController(urls: urls, currentIndex: index)
        controller.show()
    }
}

// MARK: - Quick Look Controller

private class QuickLookController: NSObject, QLPreviewPanelDataSource, QLPreviewPanelDelegate {
    let urls: [URL]
    var currentIndex: Int

    init(urls: [URL], currentIndex: Int) {
        self.urls = urls
        self.currentIndex = currentIndex
    }

    func show() {
        guard let panel = QLPreviewPanel.shared() else { return }
        panel.dataSource = self
        panel.delegate = self
        panel.currentPreviewItemIndex = currentIndex
        panel.makeKeyAndOrderFront(nil)
    }

    // MARK: - QLPreviewPanelDataSource

    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        urls.count
    }

    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        urls[index] as NSURL
    }

    // MARK: - QLPreviewPanelDelegate

    func previewPanel(_ panel: QLPreviewPanel!, handle event: NSEvent!) -> Bool {
        // Handle Space key to close
        if event.type == .keyDown && event.keyCode == 49 {  // kVK_Space
            panel.close()
            return true
        }
        return false
    }
}
