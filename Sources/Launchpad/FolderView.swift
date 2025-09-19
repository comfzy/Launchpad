import SwiftUI
import AppKit

struct FolderView: View {
    @ObservedObject var folder: FolderModel
    @State private var isHovered = false
    @State private var isPressed = false
    @State private var isDropTarget = false
    let onOpen: () -> Void
    let onRename: (String) -> Void

    var body: some View {
        VStack(spacing: 8) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.08)) {
                    isPressed = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isPressed = false
                    }
                    onOpen()
                }
            }) {
                ZStack {
                    // 文件夹背景
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                Color(folder.color.primaryColor),
                                Color(folder.color.secondaryColor)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 80, height: 80)

                    // 应用预览网格
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 2),
                        GridItem(.flexible(), spacing: 2)
                    ], spacing: 2) {
                        ForEach(0..<4, id: \.self) { index in
                            if index < folder.previewApps.count {
                                Group {
                                    if let icon = folder.previewApps[index].icon {
                                        Image(nsImage: icon)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    } else {
                                        Rectangle()
                                            .fill(.white.opacity(0.3))
                                            .overlay(
                                                Image(systemName: "app")
                                                    .font(.system(size: 8))
                                                    .foregroundColor(.white.opacity(0.8))
                                            )
                                    }
                                }
                                .frame(width: 16, height: 16)
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                            } else {
                                Rectangle()
                                    .fill(.white.opacity(0.2))
                                    .frame(width: 16, height: 16)
                                    .clipShape(RoundedRectangle(cornerRadius: 3))
                            }
                        }
                    }
                    .frame(width: 36, height: 36)

                    // 文件夹图标覆盖
                    Image(systemName: "folder.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.3))
                        .blendMode(.overlay)
                }
                .scaleEffect(isPressed ? 0.9 : (isHovered ? 1.05 : 1.0))
                .shadow(
                    color: .black.opacity(isHovered ? 0.4 : 0.2),
                    radius: isHovered ? 12 : 6,
                    x: 0,
                    y: isHovered ? 6 : 3
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isDropTarget ? Color.white : Color.clear, lineWidth: 2)
                        .scaleEffect(1.1)
                )
                .animation(.easeInOut(duration: 0.2), value: isHovered)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
                .animation(.easeInOut(duration: 0.15), value: isDropTarget)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
            }
            .contextMenu {
                Button("重命名") {
                    showRenameDialog()
                }
                Button("删除文件夹") {
                    // TODO: 实现删除功能
                }
            }

            Text(folder.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 90)
                .opacity(isHovered ? 1.0 : 0.9)
                .animation(.easeInOut(duration: 0.2), value: isHovered)
        }
        .padding(4)
    }

    private func showRenameDialog() {
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
                onRename(newName)
            }
        }
    }
}

#Preview {
    let folder = FolderModel(name: "工作应用", color: .blue)
    return FolderView(folder: folder, onOpen: {}, onRename: { _ in })
        .background(Color.black)
}