import SwiftUI

struct MainView: View {
    @StateObject private var engine = TerminalEngine()

    var body: some View {
        ZStack {
            LiquidBackground()

            TerminalViewRepresentable(engine: engine)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .padding(12)
        }
        .ignoresSafeArea()
    }
}
