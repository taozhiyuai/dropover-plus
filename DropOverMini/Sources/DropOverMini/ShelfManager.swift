import SwiftUI
import AppKit

// MARK: - Delegate

protocol ShelfManagerDelegate: AnyObject {
    func shelfManagerDidUpdate()
}

// MARK: - Shelf Manager

class ShelfManager: ObservableObject {
    @Published var shelves: [Shelf] = []
    weak var delegate: ShelfManagerDelegate?

    /// Shelf UUID → shelf window controller mapping
    var windowControllers: [UUID: ShelfWindowController] = [:]

    /// UserDefaults key for persistence
    private let storageKey = "DropOverMiniShelves"

    init() {
        loadState()
    }

    // MARK: - Create & Show

    /// Create a new shelf with optional files and show it on screen
    func createShelf(withFiles urls: [URL]) {
        let shelf = Shelf(fileURLs: urls)
        shelves.insert(shelf, at: 0)
        showShelfWindow(for: shelf)
        saveState()
        delegate?.shelfManagerDidUpdate()
    }

    /// Show an existing shelf window (bring to front or recreate)
    func showShelf(withId id: UUID) {
        guard let shelf = shelves.first(where: { $0.id == id }) else { return }
        if let controller = windowControllers[id] {
            controller.showWindow(nil)
            controller.window?.orderFrontRegardless()
        } else {
            showShelfWindow(for: shelf)
        }
        shelf.touch()
        saveState()
    }

    /// Remove a shelf
    func removeShelf(_ id: UUID) {
        shelves.removeAll(where: { $0.id == id })
        windowControllers[id]?.close()
        windowControllers.removeValue(forKey: id)
        saveState()
        delegate?.shelfManagerDidUpdate()
    }

    /// Add files to an existing shelf
    func addFiles(_ urls: [URL], to shelfId: UUID) {
        guard let shelf = shelves.first(where: { $0.id == shelfId }) else { return }
        shelf.fileURLs.append(contentsOf: urls)
        shelf.touch()
        saveState()
        delegate?.shelfManagerDidUpdate()
        // Refresh the window if it's open
        windowControllers[shelfId]?.refreshContentView()
    }

    /// Remove a specific file from a shelf
    func removeFile(at index: Int, from shelfId: UUID) {
        guard let shelf = shelves.first(where: { $0.id == shelfId }),
              index >= 0, index < shelf.fileURLs.count else { return }
        shelf.fileURLs.remove(at: index)
        shelf.touch()
        saveState()
        delegate?.shelfManagerDidUpdate()
        windowControllers[shelfId]?.refreshContentView()
    }

    /// Get recently used shelves (for menu display)
    func recentShelves() -> [Shelf] {
        shelves
            .sorted { $0.lastUsedAt > $1.lastUsedAt }
            .prefix(5)
            .map { $0 }
    }

    // MARK: - Window Management

    private func showShelfWindow(for shelf: Shelf) {
        let controller = ShelfWindowController(shelf: shelf, manager: self)
        windowControllers[shelf.id] = controller
        controller.showWindow(nil)
        controller.window?.orderFrontRegardless()
    }

    func shelfWindowDidClose(_ id: UUID) {
        windowControllers.removeValue(forKey: id)
    }

    // MARK: - Persistence

    private func stateFilePath() -> URL {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appDir = paths[0].appendingPathComponent("DropOverMini")
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        return appDir.appendingPathComponent("shelves.json")
    }

    func saveState() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(shelves)
            try data.write(to: stateFilePath())
        } catch {
            print(L.saveFailed(error.localizedDescription))
        }
    }

    private func loadState() {
        let url = stateFilePath()
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let loaded = try decoder.decode([Shelf].self, from: data)
            shelves = loaded
        } catch {
            print(L.loadFailed(error.localizedDescription))
        }
    }
}
