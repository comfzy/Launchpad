import Foundation

enum LaunchpadItem: Identifiable {
    case app(AppModel)
    case folder(FolderModel)

    var id: String {
        switch self {
        case .app(let app):
            return "app_\(app.id)"
        case .folder(let folder):
            return "folder_\(folder.id)"
        }
    }
}