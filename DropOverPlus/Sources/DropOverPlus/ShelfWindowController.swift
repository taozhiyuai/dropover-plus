import AppKit
import SwiftUI

// MARK: - Shelf Window Controller

class ShelfWindowController: NSWindowController {
    private let shelf: Shelf
    private unowned let manager: ShelfManager
    private let hostingView: NSHostingView<ShelfPanelView>

    init(shelf: Shelf, manager: ShelfManager) {
        self.shelf = shelf
        self.manager = manager

        // Build a compact floating panel
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 400),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false
        )
        panel.title = ""
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.isMovableByWindowBackground = false
        panel.hidesOnDeactivate = false
        panel.titlebarAppearsTransparent = true
        panel.isOpaque = false
        panel.backgroundColor = NSColor.controlBackgroundColor.withAlphaComponent(0.97)
        panel.hasShadow = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.minSize = NSSize(width: 240, height: 200)

        // Content view via SwiftUI
        let contentView = ShelfPanelView(shelf: shelf, manager: manager)
        hostingView = NSHostingView(rootView: contentView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        hostingView.setContentHuggingPriority(.defaultLow, for: .vertical)

        panel.contentView = hostingView
        panel.titlebarSeparatorStyle = .none

        // Call super.init BEFORE using self
        super.init(window: panel)

        panel.delegate = self
        setupConstraints()

        // Position near the menu bar area, cascading
        // (moved after super.init to avoid 'self used before super.init')
        if let visibleFrame = NSScreen.main?.visibleFrame {
            let cascadeOffset = calculateCascadeOffset()
            let x = visibleFrame.maxX - 340 - CGFloat(cascadeOffset)
            let y = visibleFrame.maxY - 420 - CGFloat(cascadeOffset)
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        guard let contentView = window?.contentView else { return }
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    /// Cascade shelf windows so they don't overlap perfectly
    private var cascadeCount: Int = 0
    private func calculateCascadeOffset() -> CGFloat {
        cascadeCount = (cascadeCount + 1) % 8
        let existing = manager.numberOfOpenShelves()
        return CGFloat(existing * 28)
    }

    func refreshContentView() {
        hostingView.rootView = ShelfPanelView(shelf: shelf, manager: manager)
    }

    override func close() {
        manager.shelfWindowDidClose(shelf.id)
        manager.saveState()
        super.close()
    }
}

// MARK: - NSWindowDelegate

extension ShelfWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        manager.shelfWindowDidClose(shelf.id)
        manager.saveState()
    }
}

// MARK: - Helper on ShelfManager

extension ShelfManager {
    func numberOfOpenShelves() -> Int {
        windowControllers.count
    }
}
