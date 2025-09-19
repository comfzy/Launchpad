import SwiftUI

struct FolderContentView: View {
    @ObservedObject var folder: FolderModel
    let onBack: () -> Void
    let onLaunchApp: (AppModel) -> Void
    @State private var searchText = ""

    private var filteredApps: [AppModel] {
        if searchText.isEmpty {
            return folder.apps
        } else {
            return folder.apps.filter { app in
                app.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    // 动态计算列数
    private var columns: [GridItem] {
        let screenWidth = NSScreen.main?.frame.width ?? 1920
        let iconWidth: CGFloat = 100
        let spacing: CGFloat = 20
        let margins: CGFloat = 200
        let availableWidth = screenWidth - margins
        let columnsCount = max(4, Int(availableWidth / (iconWidth + spacing)))
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: columnsCount)
    }

    var body: some View {
        ZStack {
            // 全屏毛玻璃背景
            VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // 标题栏
                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            Text("返回")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial.opacity(0.3))
                        .cornerRadius(20)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text(folder.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Spacer()

                    // 占位符保持对称
                    Color.clear
                        .frame(width: 80, height: 36)
                }
                .padding(.horizontal, 40)

                // 搜索栏（如果应用较多时显示）
                if folder.apps.count > 12 {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 16))

                        TextField("在 \(folder.name) 中搜索", text: $searchText)
                            .textFieldStyle(.plain)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial.opacity(0.3))
                    .cornerRadius(20)
                    .frame(maxWidth: 300)
                }

                // 应用网格
                if filteredApps.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: searchText.isEmpty ? "folder" : "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.6))
                        Text(searchText.isEmpty ? "文件夹为空" : "没有匹配的应用")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))

                        if searchText.isEmpty {
                            Text("拖拽应用到此文件夹来整理它们")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 30) {
                            ForEach(filteredApps) { app in
                                AppIconView(app: app) {
                                    onLaunchApp(app)
                                }
                                .contextMenu {
                                    Button("从文件夹移除") {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            folder.removeApp(app)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 100)
                        .padding(.bottom, 100)
                    }
                }

                Spacer()
            }
        }
        .onKeyPress(.escape) {
            onBack()
            return .handled
        }
        .onTapGesture {
            // 点击空白区域返回
            onBack()
        }
    }
}