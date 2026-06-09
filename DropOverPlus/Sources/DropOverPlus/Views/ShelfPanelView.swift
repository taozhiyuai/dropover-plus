import SwiftUI
import AppKit
import UniformTypeIdentifiers
import Quartz

// MARK: - Shelf Panel View

struct ShelfPanelView: View {
    @ObservedObject var shelf: Shelf
    let manager: ShelfManager

    @State private var isDragOver = false
    @State private var selectedURLs: Set<URL> = []
    @State private var pendingDragFiles: Set<URL> = []
    @State private var showDragAction = false
    @State private var windowDragOrigin: CGPoint = .zero
    @State private var isDraggingWindow = false
    @State private var keyMonitor: Any?

    var body: some View {
        VStack(spacing: 0) {
            titleBar
            Divider()
            contentArea
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isDragOver ? Color.accentColor.opacity(0.1) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(
                    isDragOver ? Color.accentColor : Color.clear,
                    lineWidth: isDragOver ? 2 : 0
                )
        )
        .alert(L.dragCompleteTitle, isPresented: $showDragAction) {
            Button(L.dragMove) {
                for url in pendingDragFiles {
                    if FileManager.default.fileExists(atPath: url.path) {
                        try? FileManager.default.trashItem(at: url, resultingItemURL: nil)
                    }
                }
                withAnimation {
                    for url in pendingDragFiles {
                        if let idx = shelf.fileURLs.firstIndex(of: url) {
                            manager.removeFile(at: idx, from: shelf.id)
                        }
                    }
                }
            }
            Button(L.dragKeep, role: .cancel) {
                // Finder 已复制文件，Shelf 保持不变
            }
        } message: {
            if pendingDragFiles.count == 1,
               let name = pendingDragFiles.first?.lastPathComponent {
                Text(L.dragCompleteSingle(name))
            } else {
                Text(L.dragCompleteMulti(pendingDragFiles.count))
            }
        }
        .onDrop(
            of: [.fileURL, .url],
            isTargeted: $isDragOver
        ) { providers in
            handleDrop(providers)
        }
        .onAppear { setupKeyMonitor() }
        .onDisappear {
            if let monitor = keyMonitor {
                NSEvent.removeMonitor(monitor)
            }
        }
    }

    // MARK: - Keyboard Shortcuts

    private func setupKeyMonitor() {
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [self] event in
            if event.modifierFlags.contains(.command),
               event.charactersIgnoringModifiers?.lowercased() == "a" {
                selectedURLs = Set(shelf.fileURLs)
                return nil // 已处理
            }
            return event
        }
    }

    // MARK: - Title Bar

    private var titleBar: some View {
        HStack {
            Image(systemName: "tray.fill")
                .foregroundColor(.accentColor)
                .font(.caption)
            Text(shelf.title)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
            Spacer()
            Text(shelf.displayFileCount)
                .font(.caption2)
                .foregroundColor(.secondary)
            Menu {
                Text(L.created(shelf.prettyCreatedAt))
                Text(L.totalSize(shelf.estimatedTotalSize))
                Divider()
                Button(L.clearShelf) {
                    manager.removeShelf(shelf.id)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .frame(width: 20)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .contentShape(Rectangle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    guard let window = NSApp.keyWindow else { return }
                    if !isDraggingWindow {
                        isDraggingWindow = true
                        windowDragOrigin = window.frame.origin
                    }
                    window.setFrameOrigin(CGPoint(
                        x: windowDragOrigin.x + value.translation.width,
                        y: windowDragOrigin.y - value.translation.height
                    ))
                }
                .onEnded { _ in
                    isDraggingWindow = false
                }
        )
    }

    // MARK: - Content Area

    @ViewBuilder
    private var contentArea: some View {
        VStack(spacing: 0) {
            if shelf.fileURLs.isEmpty {
                emptyDropZone
            } else {
                fileGrid
            }

            if !shelf.fileURLs.isEmpty {
                Divider()
                HStack {
                    Spacer()
                    Button(role: .destructive) {
                        withAnimation {
                            manager.removeShelf(shelf.id)
                        }
                    } label: {
                        Label(L.clearShelf, systemImage: "trash")
                            .font(.caption)
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(.red.opacity(0.7))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .help(L.clearShelf)
                    Spacer()
                }
                .padding(.vertical, 6)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { selectedURLs.removeAll() }
    }

    private var emptyDropZone: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 36))
                .foregroundColor(.secondary.opacity(0.5))
            Text(L.dragHint)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("或点击按钮添加文件")
                .font(.caption2)
                .foregroundColor(.secondary.opacity(0.8))
            Button {
                addFilesFromDialog()
            } label: {
                Label(L.addFiles, systemImage: "plus")
                    .font(.caption)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - File Grid

    private var fileGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 80, maximum: 120), spacing: 8)],
                spacing: 8
            ) {
                ForEach(Array(shelf.fileURLs.enumerated()), id: \.element) { index, url in
                    FileCellView(
                        url: url,
                        index: index,
                        isSelected: selectedURLs.contains(url),
                        selectedURLs: selectedURLs,
                        onTap: {
                            if selectedURLs.contains(url) {
                                selectedURLs.remove(url)
                            } else {
                                selectedURLs.insert(url)
                            }
                        },
                        onRemove: {
                            manager.removeFile(at: index, from: shelf.id)
                        },
                        onDragFilesEnded: { draggedURLs in
                            pendingDragFiles = draggedURLs
                            showDragAction = true
                        }
                    )
                }
            }
            .padding(8)
        }
    }

    // MARK: - Drop Handling

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        var accepted = false
        for provider in providers {
            if provider.canLoadObject(ofClass: NSURL.self) {
                provider.loadObject(ofClass: NSURL.self) { object, _ in
                    if let url = object as? URL {
                        DispatchQueue.main.async {
                            self.manager.addFiles([url], to: self.shelf.id)
                        }
                    }
                }
                accepted = true
                continue
            }
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { data, _ in
                    guard let data else { return }
                    if let urlString = String(data: data, encoding: .utf8),
                       let url = URL(string: urlString) {
                        DispatchQueue.main.async {
                            self.manager.addFiles([url], to: self.shelf.id)
                        }
                    }
                }
                accepted = true
            }
        }
        return accepted
    }

    private func addFilesFromDialog() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        panel.message = L.selectFiles
        panel.begin { response in
            if response == .OK {
                manager.addFiles(panel.urls, to: shelf.id)
            }
        }
    }
}

// MARK: - File Cell View

struct FileCellView: View {
    let url: URL
    let index: Int
    let isSelected: Bool
    let selectedURLs: Set<URL>
    let onTap: () -> Void
    let onRemove: () -> Void
    let onDragFilesEnded: (Set<URL>) -> Void

    @State private var icon: NSImage?
    @State private var displayName: String = ""
    @State private var isHovered = false
    @State private var dragGeneration = 0

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(0.08))
                    .aspectRatio(1, contentMode: .fit)

                if let icon {
                    Image(nsImage: icon)
                        .resizable()
                        .renderingMode(.original)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 36, height: 36)
                } else {
                    Image(systemName: "doc.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        isHovered ? Color.accentColor : Color.clear,
                        lineWidth: 1.5
                    )
            )

            Text(displayName)
                .font(.caption2)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    isSelected ? Color.green.opacity(0.15) :
                    isHovered ? Color.accentColor.opacity(0.06) :
                    Color.clear
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 8))
        .onHover { hovering in isHovered = hovering }
        .contextMenu {
            Button(L.ctxOpen) { NSWorkspace.shared.open(url) }
            Button(L.ctxShowInFinder) {
                NSWorkspace.shared.activateFileViewerSelecting([url])
            }
            Divider()
            Button(L.ctxQuickLook) {
                QuickLookService.preview(urls: [url], at: 0)
            }
            Button(L.ctxCopy) {
                let pb = NSPasteboard.general
                pb.clearContents()
                pb.writeObjects([url as NSURL])
            }
            Divider()
            Button(L.ctxRemove, role: .destructive) {
                withAnimation { onRemove() }
            }
        }
        // ★ DragSourceRep 覆盖在 Cell 上，拦截鼠标并创建原生拖拽会话
        .overlay(alignment: .center) {
            DragSourceRep(
                url: url,
                selectedURLs: selectedURLs,
                onDragEnded: { operation, draggedURLs in
                    onDragFilesEnded(draggedURLs)
                },
                onTap: {
                    onTap()
                }
            )
        }
        .id("cell-\(url)-\(dragGeneration)")
        .onAppear { loadFileInfo() }
        .onChange(of: url) { _, _ in loadFileInfo() }
    }

    private func loadFileInfo() {
        displayName = url.lastPathComponent
        DispatchQueue.global(qos: .userInitiated).async {
            let nsIcon = NSWorkspace.shared.icon(forFile: url.path)
            DispatchQueue.main.async {
                self.icon = nsIcon
            }
        }
    }
}

// MARK: - DragSourceRep

struct DragSourceRep: NSViewRepresentable {
    let url: URL
    let selectedURLs: Set<URL>
    let onDragEnded: (NSDragOperation, Set<URL>) -> Void
    let onTap: (() -> Void)?

    init(url: URL, selectedURLs: Set<URL> = [], onDragEnded: @escaping (NSDragOperation, Set<URL>) -> Void, onTap: (() -> Void)? = nil) {
        self.url = url
        self.selectedURLs = selectedURLs
        self.onDragEnded = onDragEnded
        self.onTap = onTap
    }

    func makeNSView(context: Context) -> DragNSView {
        let view = DragNSView()
        view.url = url
        view.onDragEnded = onDragEnded
        view.onTap = onTap
        return view
    }

    func updateNSView(_ nsView: DragNSView, context: Context) {
        nsView.url = url
        nsView.selectedURLs = selectedURLs
        nsView.onTap = onTap
        // ★ 关键：确保 NSView frame 匹配父视图，否则 hitTest 收不到事件
        if let sv = nsView.superview {
            let fb = sv.bounds
            if !nsView.frame.equalTo(fb) {
                nsView.frame = fb
                nsView.autoresizingMask = [.width, .height]
            }
        }
    }
}

class DragNSView: NSView {
    var url: URL?
    var selectedURLs: Set<URL> = []
    var onDragEnded: ((NSDragOperation, Set<URL>) -> Void)?
    var onTap: (() -> Void)?
    private var mouseDownLocation: NSPoint = .zero
    private var dragStarted = false
    private var currentDraggedURLs: Set<URL> = []

    init() {
        super.init(frame: .zero)
        // ★ 允许视图接收鼠标事件
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Hit Testing

    override func hitTest(_ point: NSPoint) -> NSView? {
        guard bounds.contains(point) else { return nil }
        return self
    }

    // MARK: - 鼠标事件
    // ★ 不转发 mouseDown，避免 ScrollView 吞噬拖拽手势

    override func mouseDown(with event: NSEvent) {
        mouseDownLocation = event.locationInWindow
        dragStarted = false
    }

    override func mouseDragged(with event: NSEvent) {
        let loc = event.locationInWindow
        guard hypot(loc.x - mouseDownLocation.x, loc.y - mouseDownLocation.y) > 5,
              !dragStarted, let url else { return }
        dragStarted = true

        // 决定要拖拽哪些文件
        let dragURLs: [URL]
        if selectedURLs.contains(url), selectedURLs.count > 1 {
            dragURLs = Array(selectedURLs)
        } else {
            dragURLs = [url]
        }
        currentDraggedURLs = Set(dragURLs)

        let iconSize = NSSize(width: 48, height: 48)
        let items: [NSDraggingItem] = dragURLs.enumerated().map { idx, fileURL in
            let writer = fileURL as NSURL
            let item = NSDraggingItem(pasteboardWriter: writer)

            let icon = NSWorkspace.shared.icon(forFile: fileURL.path)
            icon.size = iconSize
            // 多文件时依次偏移，形成叠放效果
            let offset = CGFloat(idx) * 4
            item.setDraggingFrame(
                NSRect(x: -12 + offset, y: -12 - offset, width: 48, height: 48),
                contents: icon
            )
            return item
        }

        beginDraggingSession(with: items, event: event, source: self)
    }

    override func mouseUp(with event: NSEvent) {
        if !dragStarted {
            onTap?()
        }
        dragStarted = false
    }

    override func rightMouseDown(with event: NSEvent) {
        nextResponder?.rightMouseDown(with: event)
    }

    override func rightMouseUp(with event: NSEvent) {
        nextResponder?.rightMouseUp(with: event)
    }

    // MARK: - Hover 转发

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach { removeTrackingArea($0) }
        let ta = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeInActiveApp, .mouseMoved],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(ta)
    }

    override func mouseEntered(with event: NSEvent) {
        nextResponder?.mouseEntered(with: event)
    }

    override func mouseExited(with event: NSEvent) {
        nextResponder?.mouseExited(with: event)
    }
}

// MARK: - NSDraggingSource

extension DragNSView: NSDraggingSource {
    // ★ 只允许复制操作，Finder 不会移动源文件
    //   原文件始终保留，用户通过对话框选择「移动」时才清理
    func draggingSession(
        _ session: NSDraggingSession,
        sourceOperationMaskFor context: NSDraggingContext
    ) -> NSDragOperation {
        [.copy]
    }

    func draggingSession(
        _ session: NSDraggingSession,
        endedAt screenPoint: NSPoint,
        operation: NSDragOperation
    ) {
        guard operation != [] else { return }
        let urls = currentDraggedURLs
        currentDraggedURLs = []
        DispatchQueue.main.async {
            self.onDragEnded?(operation, urls)
        }
    }
}
