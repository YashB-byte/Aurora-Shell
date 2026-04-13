import SwiftUI

struct MainView: View {
    @StateObject private var engine = TerminalEngine()

    var body: some View {
        ZStack {
            LiquidBackground()

            // Frosted glass panel behind terminal
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .opacity(0.6)
                .padding(8)

            TerminalViewRepresentable(engine: engine)
                .background(.clear)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(12)
        }
        .ignoresSafeArea()
    }
}
