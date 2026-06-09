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
                    Label(L.settingsGeneral, systemImage: "gearshape")
                }

            aboutTab
                .tabItem {
                    Label(L.settingsAbout, systemImage: "info.circle")
                }
        }
        .frame(width: 400, height: 320)
    }

    // MARK: - General

    private var generalSettings: some View {
        Form {
            Section {
                Toggle(L.closeAfterDrag, isOn: $closeAfterDragOut)

                Toggle(L.floatOnTop, isOn: $floatingOnTop)
                    .onChange(of: floatingOnTop) { _, newValue in
                        updateAllWindowsLevel(newValue)
                    }
            }

            Section {
                Stepper(L.maxRecent(maxRecentShelves), value: $maxRecentShelves, in: 1...20)
            }

            Section(L.shortcuts) {
                HStack {
                    Text(L.newShelfKey)
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

            Text(L.version("v1.0.0", L.appTagline))
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(L.aboutDesc)
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
