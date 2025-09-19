import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var appScanner = AppScanner()
    @StateObject private var folderManager = FolderManager()
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFolder: FolderModel?
    @State private var showingCreateFolder = false
    @State private var draggedApp: AppModel?

    private var filteredApps: [AppModel] {
        let appsInFolders = folderManager.getAppsInFolders()
        let availableApps = appScanner.apps.filter { !appsInFolders.contains($0.bundleIdentifier) }

        if searchText.isEmpty {
            return availableApps
        } else {
            return availableApps.filter { app in
                app.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    private var allItems: [LaunchpadItem] {
        var items: [LaunchpadItem] = []

        // 添加文件夹
        for folder in folderManager.folders {
            items.append(.folder(folder))
        }

        // 添加应用
        for app in filteredApps {
            items.append(.app(app))
        }

        return items
    }

    // 动态计算列数基于屏幕宽度
    private var columns: [GridItem] {
        let screenWidth = NSScreen.main?.frame.width ?? 1920
        let iconWidth: CGFloat = 100
        let spacing: CGFloat = 20
        let margins: CGFloat = 200
        let availableWidth = screenWidth - margins
        let columnsCount = max(6, Int(availableWidth / (iconWidth + spacing)))
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: columnsCount)
    }

    var body: some View {
        Group {
            if let selectedFolder = selectedFolder {
                FolderContentView(
                    folder: selectedFolder,
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self.selectedFolder = nil
                        }
                    },
                    onLaunchApp: { app in
                        appScanner.launchApp(app)
                        NSApplication.shared.hide(nil)
                    }
                )
            } else {
                mainLaunchpadView
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedFolder)
    }

    private var mainLaunchpadView: some View {
        ZStack {
            // 全屏毛玻璃背景
            VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // 顶部工具栏
                HStack {
                    Button(action: {
                        showingCreateFolder = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "folder.badge.plus")
                                .font(.system(size: 16))
                            Text("新建文件夹")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial.opacity(0.3))
                        .cornerRadius(15)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
                .padding(.horizontal, 40)

                // 搜索栏
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 18))

                    TextField("搜索", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .focused($isSearchFocused)
                        .onSubmit {
                            if let firstApp = filteredApps.first {
                                appScanner.launchApp(firstApp)
                                NSApplication.shared.hide(nil)
                            }
                        }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial.opacity(0.3))
                .cornerRadius(25)
                .frame(maxWidth: 400)

                // 主内容区域
                if appScanner.isScanning && appScanner.apps.isEmpty {
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        Text("正在加载应用...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                } else if allItems.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "app.dashed")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.6))
                        Text(searchText.isEmpty ? "没有找到应用" : "没有匹配的应用")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 30) {
                            ForEach(allItems, id: \.id) { item in
                                itemView(for: item)
                            }
                        }
                        .padding(.horizontal, 100)
                        .padding(.bottom, 100)
                    }
                }

                Spacer()
            }
        }
        .onAppear {
            if appScanner.apps.isEmpty {
                appScanner.scanForApps()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isSearchFocused = true
            }
        }
        .onKeyPress(.escape) {
            NSApplication.shared.terminate(nil)
            return .handled
        }
        .onTapGesture {
            NSApplication.shared.terminate(nil)
        }
        .sheet(isPresented: $showingCreateFolder) {
            CreateFolderSheet(folderManager: folderManager)
        }
    }

    @ViewBuilder
    private func itemView(for item: LaunchpadItem) -> some View {
        switch item {
        case .app(let app):
            AppIconView(app: app) {
                appScanner.launchApp(app)
                NSApplication.shared.hide(nil)
            }
            .onDrag {
                draggedApp = app
                print("Starting drag for app: \(app.name)")
                let provider = NSItemProvider()
                provider.registerObject("app:\(app.bundleIdentifier)" as NSString, visibility: .all)
                return provider
            }
            .contextMenu {
                if !folderManager.folders.isEmpty {
                    Menu("移动到文件夹") {
                        ForEach(folderManager.folders) { folder in
                            Button(folder.name) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    folderManager.addAppToFolder(app: app, folder: folder)
                                }
                            }
                            .disabled(folder.apps.contains(where: { $0.bundleIdentifier == app.bundleIdentifier }))
                        }
                    }
                }
            }

        case .folder(let folder):
            FolderView(folder: folder) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedFolder = folder
                }
            } onRename: { newName in
                folderManager.renameFolder(folder, to: newName)
            }
            .onDrop(of: [UTType.text], isTargeted: .constant(false)) { providers, location in
                return handleDropOnFolder(providers: providers, folder: folder)
            }
            .contextMenu {
                Button("重命名") {
                    showRenameDialog(for: folder)
                }
                Divider()
                Button("删除文件夹", role: .destructive) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        folderManager.deleteFolder(folder)
                    }
                }
            }
        }
    }

    private func handleDropOnFolder(providers: [NSItemProvider], folder: FolderModel) -> Bool {
        guard let draggedApp = draggedApp else {
            print("No dragged app found")
            return false
        }

        print("Dropping app '\(draggedApp.name)' into folder '\(folder.name)'")

        // 检查应用是否已经在文件夹中
        if folder.apps.contains(where: { $0.bundleIdentifier == draggedApp.bundleIdentifier }) {
            print("App already in folder")
            self.draggedApp = nil
            return false
        }

        // 添加应用到文件夹
        folderManager.addAppToFolder(app: draggedApp, folder: folder)
        self.draggedApp = nil

        // 提供触觉反馈
        NSSound.beep()

        print("Successfully added app to folder")
        return true
    }

    private func showRenameDialog(for folder: FolderModel) {
        let alert = NSAlert()
        alert.messageText = "重命名文件夹"
        alert.informativeText = "请输入新的文件夹名称:"
        alert.addButton(withTitle: "确定")
        alert.addButton(withTitle: "取消")

        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        textField.stringValue = folder.name
        alert.accessoryView = textField

        if alert.runModal() == .alertFirstButtonReturn {
            let newName = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !newName.isEmpty {
                folderManager.renameFolder(folder, to: newName)
            }
        }
    }
}

struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }

    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}