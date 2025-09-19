# Launchpad

一个现代化的 macOS 应用启动器，提供类似 iOS Launchpad 的体验。

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![Platform](https://img.shields.io/badge/Platform-macOS%2014+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## 特性

- 🚀 **快速启动**：一键快速启动系统中的任何应用程序
- 📁 **文件夹管理**：创建文件夹并通过拖拽整理应用程序
- 🔍 **智能搜索**：实时搜索应用程序，支持中英文名称
- 🎨 **美观界面**：全屏毛玻璃效果，现代化的用户界面
- ⚡ **高性能**：异步应用扫描，流畅的动画效果
- 🎯 **快捷操作**：支持右键菜单、拖拽操作等
- ⌨️ **键盘支持**：ESC 键退出，Enter 键启动搜索结果

## 系统要求

- macOS 14.0 或更高版本
- Xcode 15.0 或更高版本（开发环境）

## 安装

### 🔥 推荐：下载预编译版本

1. 前往 [Releases 页面](https://github.com/comfzy/Launchpad/releases)
2. 下载最新版本的 `Launchpad.zip`
3. 解压后双击 `Launchpad.app` 即可使用

### 📦 从源码构建

1. 克隆仓库：
```bash
git clone https://github.com/comfzy/Launchpad.git
cd Launchpad
```

2. 使用 Swift Package Manager 构建：
```bash
swift build -c release
```

3. 运行应用：
```bash
swift run
```

### 使用 Xcode

1. 在 Xcode 中打开 `Package.swift`
2. 选择 Launchpad scheme
3. 点击运行按钮或按 `Cmd+R`

## 使用方法

### 基本操作

1. **启动应用**：点击应用图标即可启动
2. **搜索应用**：在搜索框中输入应用名称，支持模糊匹配
3. **退出程序**：按 ESC 键或点击空白区域

### 文件夹管理

1. **创建文件夹**：点击左上角的"新建文件夹"按钮
2. **添加应用到文件夹**：将应用拖拽到文件夹上
3. **打开文件夹**：点击文件夹图标查看内部应用
4. **重命名文件夹**：右键点击文件夹选择"重命名"
5. **删除文件夹**：右键点击文件夹选择"删除文件夹"

### 快捷操作

- **右键菜单**：右键点击应用可查看移动到文件夹选项
- **拖拽整理**：将应用拖拽到文件夹中进行整理
- **快速启动**：在搜索框中输入应用名称后按 Enter 键

## 项目结构

```
Launchpad/
├── Package.swift              # Swift Package 配置
├── Sources/
│   └── Launchpad/
│       ├── LaunchpadApp.swift     # 应用入口
│       ├── ContentView.swift      # 主界面视图
│       ├── AppModel.swift         # 应用数据模型
│       ├── AppScanner.swift       # 应用扫描器
│       ├── AppIconView.swift      # 应用图标视图
│       ├── FolderModel.swift      # 文件夹数据模型
│       ├── FolderManager.swift    # 文件夹管理器
│       ├── FolderView.swift       # 文件夹视图
│       ├── FolderContentView.swift # 文件夹内容视图
│       ├── CreateFolderSheet.swift # 创建文件夹弹窗
│       └── LaunchpadItem.swift    # 启动项枚举
└── README.md
```

## 技术特点

- **SwiftUI**：使用现代化的 SwiftUI 框架构建用户界面
- **Combine**：响应式编程，数据绑定和状态管理
- **NSWorkspace**：与 macOS 系统集成，获取应用信息和启动应用
- **UserDefaults**：持久化存储文件夹配置
- **异步编程**：使用 GCD 进行后台应用扫描
- **拖拽支持**：实现应用到文件夹的拖拽功能

## 开发

### 贡献指南

欢迎贡献代码！请遵循以下步骤：

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 代码风格

- 使用 Swift 官方代码风格
- 保持代码简洁和可读性
- 添加必要的注释，特别是复杂逻辑部分
- 遵循 SwiftUI 最佳实践

### 已知问题

- 某些系统应用可能无法正确获取图标
- 大量应用时初次扫描可能需要一些时间

## 许可证

本项目基于 MIT 许可证开源。详情请查看 [LICENSE](LICENSE) 文件。

## 致谢

- 感谢 Apple 提供的优秀 SwiftUI 框架
- 感谢开源社区的贡献和支持

## 更新日志

### v1.0.0 (即将发布)

- 🎉 首次发布
- ✨ 应用扫描和启动功能
- 📁 文件夹管理功能
- 🔍 应用搜索功能
- 🎨 美观的全屏界面
- ⚡ 高性能异步扫描

---

如果你觉得这个项目有用，请给它一个 ⭐️！
