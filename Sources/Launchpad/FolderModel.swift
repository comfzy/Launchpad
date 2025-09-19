import Foundation
import AppKit

class FolderModel: ObservableObject, Identifiable, Codable, Equatable {
    let id = UUID()
    @Published var name: String
    @Published var apps: [AppModel] = []
    @Published var color: FolderColor

    init(name: String, color: FolderColor = .blue) {
        self.name = name
        self.color = color
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, name, apps, color
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        color = try container.decode(FolderColor.self, forKey: .color)

        // 解码应用时需要特殊处理，因为AppModel不支持Codable
        let appData = try container.decode([AppData].self, forKey: .apps)
        apps = appData.compactMap { data in
            AppModel(name: data.name, bundleIdentifier: data.bundleIdentifier, path: data.path)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(color, forKey: .color)

        // 将AppModel转换为可编码的AppData
        let appData = apps.map { AppData(name: $0.name, bundleIdentifier: $0.bundleIdentifier, path: $0.path) }
        try container.encode(appData, forKey: .apps)
    }

    func addApp(_ app: AppModel) {
        if !apps.contains(app) {
            apps.append(app)
        }
    }

    func removeApp(_ app: AppModel) {
        apps.removeAll { $0.id == app.id }
    }

    var previewApps: [AppModel] {
        Array(apps.prefix(4))
    }

    // MARK: - Equatable
    static func == (lhs: FolderModel, rhs: FolderModel) -> Bool {
        lhs.id == rhs.id
    }
}

// 用于编码/解码的简化应用数据结构
struct AppData: Codable {
    let name: String
    let bundleIdentifier: String
    let path: String
}

enum FolderColor: String, CaseIterable, Codable {
    case blue = "blue"
    case green = "green"
    case orange = "orange"
    case red = "red"
    case purple = "purple"
    case pink = "pink"

    var primaryColor: NSColor {
        switch self {
        case .blue: return NSColor.systemBlue
        case .green: return NSColor.systemGreen
        case .orange: return NSColor.systemOrange
        case .red: return NSColor.systemRed
        case .purple: return NSColor.systemPurple
        case .pink: return NSColor.systemPink
        }
    }

    var secondaryColor: NSColor {
        return primaryColor.withAlphaComponent(0.7)
    }
}