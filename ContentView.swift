import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            LiquidGlassBackground()
                .ignoresSafeArea()

            TerminalView()
                .padding()
        }
    }
}

