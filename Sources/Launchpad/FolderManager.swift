import Foundation

class FolderManager: ObservableObject {
    @Published var folders: [FolderModel] = []
    private let userDefaults = UserDefaults.standard
    private let foldersKey = "LaunchpadFolders"

    init() {
        loadFolders()
    }

    func createFolder(name: String, color: FolderColor = .blue) -> FolderModel {
        let folder = FolderModel(name: name, color: color)
        folders.append(folder)
        saveFolders()
        return folder
    }

    func deleteFolder(_ folder: FolderModel) {
        folders.removeAll { $0.id == folder.id }
        saveFolders()
    }

    func renameFolder(_ folder: FolderModel, to newName: String) {
        folder.name = newName
        saveFolders()
    }

    func addAppToFolder(app: AppModel, folder: FolderModel) {
        folder.addApp(app)
        saveFolders()
    }

    func removeAppFromFolder(app: AppModel, folder: FolderModel) {
        folder.removeApp(app)
        saveFolders()
    }

    func getAppsInFolders() -> Set<String> {
        var appsInFolders: Set<String> = []
        for folder in folders {
            for app in folder.apps {
                appsInFolders.insert(app.bundleIdentifier)
            }
        }
        return appsInFolders
    }

    private func saveFolders() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(folders)
            userDefaults.set(data, forKey: foldersKey)
        } catch {
            print("保存文件夹失败: \(error)")
        }
    }

    private func loadFolders() {
        guard let data = userDefaults.data(forKey: foldersKey) else { return }

        do {
            let decoder = JSONDecoder()
            folders = try decoder.decode([FolderModel].self, from: data)
        } catch {
            print("加载文件夹失败: \(error)")
            folders = []
        }
    }
}