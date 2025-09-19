import Foundation
import AppKit

struct AppModel: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let bundleIdentifier: String
    let path: String
    let icon: NSImage?

    init(name: String, bundleIdentifier: String, path: String) {
        self.name = name
        self.bundleIdentifier = bundleIdentifier
        self.path = path
        self.icon = Self.loadIcon(from: path)
    }

    private static func loadIcon(from path: String) -> NSImage? {
        let workspace = NSWorkspace.shared
        return workspace.icon(forFile: path)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(bundleIdentifier)
    }

    static func == (lhs: AppModel, rhs: AppModel) -> Bool {
        lhs.bundleIdentifier == rhs.bundleIdentifier
    }
}