import SwiftUI

@main
struct AuroraShellApp: App {
    init() {
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first {
                window.isOpaque = false
                window.backgroundColor = .clear
                window.titleVisibility = .hidden
                window.titlebarAppearsTransparent = true
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

