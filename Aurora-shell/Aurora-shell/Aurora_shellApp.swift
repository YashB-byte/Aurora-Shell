import SwiftUI

@main
struct Aurora_shellApp: App {
    var body: some Scene {
#if os(macOS)
        WindowGroup {
            MainView()
                .preferredColorScheme(.dark)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1000, height: 650)
#else
        WindowGroup {
            MainView()
                .preferredColorScheme(.dark)
        }
#endif
    }
}
