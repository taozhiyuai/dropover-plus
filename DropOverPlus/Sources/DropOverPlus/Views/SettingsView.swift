import SwiftUI

// MARK: - Settings View

struct SettingsView: View {
    @AppStorage("closeAfterDragOut") private var closeAfterDragOut = false
    @AppStorage("floatingOnTop") private var floatingOnTop = true
    @AppStorage("maxRecentShelves") private var maxRecentShelves = 5

    var body: some View {
        TabView {
            generalSettings
                .tabItem {
                    Label("通用", systemImage: "gearshape")
                }

            aboutTab
                .tabItem {
                    Label("关于", systemImage: "info.circle")
                }
        }
        .frame(width: 400, height: 280)
    }

    // MARK: - General

    private var generalSettings: some View {
        Form {
            Section("行为") {
                Toggle("拖出文件后关闭 Shelf", isOn: $closeAfterDragOut)

                Toggle("Shelf 窗口保持在最前", isOn: $floatingOnTop)
                    .onChange(of: floatingOnTop) { _, newValue in
                        updateAllWindowsLevel(newValue)
                    }
            }

            Section("最近 Shelf") {
                Stepper("最多保留 \(maxRecentShelves) 个", value: $maxRecentShelves, in: 1...20)
            }

            Section("快捷键") {
                HStack {
                    Text("新建 Shelf")
                    Spacer()
                    Text("⌘⇧N")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
        .padding()
    }

    // MARK: - About

    private var aboutTab: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray.full")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)

            Text("DropOverPlus")
                .font(.title2)
                .fontWeight(.semibold)

            Text("v1.0.0 — 拖放操作，重新想象")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("灵感来自 Dropover，纯 SwiftUI 实现。\n拖拽文件到 Shelf 临时存放，\n再从 Shelf 拖出到目标位置。")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Helpers

    private func updateAllWindowsLevel(_ floating: Bool) {
        let level: NSWindow.Level = floating ? .floating : .normal
        // Windows are managed by ShelfManager; we'll just access them via NSApp
        for window in NSApp.windows where window is NSPanel {
            window.level = level
        }
    }
}
