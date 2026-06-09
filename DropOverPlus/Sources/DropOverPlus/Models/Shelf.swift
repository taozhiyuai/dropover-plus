import Foundation
import UniformTypeIdentifiers

// MARK: - Shelf Model

class Shelf: Identifiable, Codable, ObservableObject {
    let id: UUID
    @Published var title: String
    @Published var fileURLs: [URL]
    let createdAt: Date
    @Published var lastUsedAt: Date

    init(id: UUID = UUID(), title: String? = nil, fileURLs: [URL] = []) {
        self.id = id
        self.title = title ?? "Shelf \(id.uuidString.prefix(8))"
        self.fileURLs = fileURLs
        self.createdAt = Date()
        self.lastUsedAt = Date()
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        let bookmarkData = try container.decode([Data].self, forKey: .fileURLs)
        fileURLs = bookmarkData.compactMap { data in
            var isStale = false
            return try? URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
        }
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        lastUsedAt = try container.decode(Date.self, forKey: .lastUsedAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        let bookmarkData = fileURLs.compactMap { url in
            try? url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        }
        try container.encode(bookmarkData, forKey: .fileURLs)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(lastUsedAt, forKey: .lastUsedAt)
    }

    func touch() {
        lastUsedAt = Date()
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id, title, fileURLs, createdAt, lastUsedAt
    }
}

// MARK: - Display Helpers

extension Shelf {
    var displayFileCount: String {
        let count = fileURLs.count
        if count == 0 { return "空" }
        return "\(count) 个文件"
    }

    var prettyCreatedAt: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }

    var estimatedTotalSize: String {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.countStyle = .file
        var total: Int64 = 0
        for url in fileURLs {
            if let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
               let size = attrs[.size] as? Int64 {
                total += size
            }
        }
        return byteCountFormatter.string(fromByteCount: total)
    }
}
