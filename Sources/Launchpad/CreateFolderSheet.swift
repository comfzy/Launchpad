import SwiftUI

struct CreateFolderSheet: View {
    @ObservedObject var folderManager: FolderManager
    @Environment(\.dismiss) private var dismiss
    @State private var folderName = ""
    @State private var selectedColor: FolderColor = .blue

    var body: some View {
        VStack(spacing: 24) {
            Text("新建文件夹")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 12) {
                Text("文件夹名称")
                    .font(.headline)
                    .foregroundColor(.secondary)

                TextField("输入文件夹名称", text: $folderName)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        createFolder()
                    }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("选择颜色")
                    .font(.headline)
                    .foregroundColor(.secondary)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(FolderColor.allCases, id: \.self) { color in
                        Button(action: {
                            selectedColor = color
                        }) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(color.primaryColor),
                                        Color(color.secondaryColor)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedColor == color ? Color.accentColor : Color.clear, lineWidth: 3)
                                )
                                .overlay(
                                    Image(systemName: "folder.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white.opacity(0.8))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            HStack(spacing: 12) {
                Button("取消") {
                    dismiss()
                }
                .buttonStyle(.borderless)

                Button("创建") {
                    createFolder()
                }
                .buttonStyle(.borderedProminent)
                .disabled(folderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 300)
        .onAppear {
            folderName = "新建文件夹"
        }
    }

    private func createFolder() {
        let name = folderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        let _ = folderManager.createFolder(name: name, color: selectedColor)
        dismiss()
    }
}

#Preview {
    CreateFolderSheet(folderManager: FolderManager())
}