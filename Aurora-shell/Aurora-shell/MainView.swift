import SwiftUI

struct MainView: View {
    var body: some View {
#if os(macOS)
        MacTerminalView()
#else
        NotMacView()
#endif
    }
}

#if os(macOS)
private struct MacTerminalView: View {
    @StateObject private var engine = TerminalEngine()

    var body: some View {
        ZStack {
            LiquidBackground()
            TerminalViewRepresentable(engine: engine)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.15), lineWidth: 1))
                .padding(12)
        }
        .ignoresSafeArea()
    }
}
#endif
