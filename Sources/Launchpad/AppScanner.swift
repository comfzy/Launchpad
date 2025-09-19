import Foundation
import AppKit

class AppScanner: ObservableObject {
    @Published var apps: [AppModel] = []
    @Published var isScanning = false

    private let appCache = NSCache<NSString, NSArray>()
    private let cacheKey = "scanned_apps"

    private let applicationDirectories = [
        "/Applications",
        "/System/Applications"
    ]

    init() {
        loadCachedApps()
    }

    func scanForApps() {
        guard !isScanning else { return }
        isScanning = true

        DispatchQueue.global(qos: .userInitiated).async {
            var discoveredApps: [AppModel] = []

            // 并行扫描不同目录
            let group = DispatchGroup()
            let queue = DispatchQueue(label: "app.scanner", qos: .userInitiated, attributes: .concurrent)

            for directory in self.applicationDirectories {
                group.enter()
                queue.async {
                    let dirApps = self.scanDirectoryFast(directory)
                    DispatchQueue.main.async {
                        discoveredApps.append(contentsOf: dirApps)
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                // 去重并排序
                let uniqueApps = Array(Set(discoveredApps)).sorted {
                    $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }

                self.apps = uniqueApps
                self.isScanning = false
                self.cacheApps(uniqueApps)
            }
        }
    }

    private func loadCachedApps() {
        if let cachedArray = appCache.object(forKey: cacheKey as NSString) as? [AppModel] {
            self.apps = cachedArray
        }
    }

    private func cacheApps(_ apps: [AppModel]) {
        appCache.setObject(apps as NSArray, forKey: cacheKey as NSString)
    }

    private func scanDirectoryFast(_ path: String) -> [AppModel] {
        let fileManager = FileManager.default
        var apps: [AppModel] = []

        guard let contents = try? fileManager.contentsOfDirectory(atPath: path) else {
            return apps
        }

        for item in contents {
            guard item.hasSuffix(".app") else { continue }

            let appPath = "\(path)/\(item)"
            guard let bundle = Bundle(path: appPath) else { continue }
            guard let bundleIdentifier = bundle.bundleIdentifier else { continue }

            let appName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
                ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
                ?? URL(fileURLWithPath: item).deletingPathExtension().lastPathComponent

            let app = AppModel(name: appName, bundleIdentifier: bundleIdentifier, path: appPath)
            apps.append(app)
        }

        return apps
    }

    func launchApp(_ app: AppModel) {
        NSWorkspace.shared.openApplication(at: URL(fileURLWithPath: app.path),
                                         configuration: NSWorkspace.OpenConfiguration(),
                                         completionHandler: nil)
    }
}