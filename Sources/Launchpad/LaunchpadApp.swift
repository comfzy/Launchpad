import SwiftUI
import AppKit

@main
struct LaunchpadApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 确保应用窗口显示在最前面
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        // 配置窗口
        if let window = NSApplication.shared.windows.first {
            window.level = .floating
            window.isOpaque = false
            window.backgroundColor = NSColor.clear
            window.hasShadow = false
            window.styleMask = [.borderless, .fullSizeContentView]

            if let screen = NSScreen.main {
                // 计算可见区域，避开Dock和菜单栏
                let visibleFrame = screen.visibleFrame
                window.setFrame(visibleFrame, display: true)
            }

            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
        }
    }
}