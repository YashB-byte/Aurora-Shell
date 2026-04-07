import SwiftUI

@main
struct Aurora_shellApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(viewModel: ShellViewModel())
        }
    }
}
