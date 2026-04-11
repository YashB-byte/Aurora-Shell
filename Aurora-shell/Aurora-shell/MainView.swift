import SwiftUI

struct MainView: View {
    @StateObject private var engine = TerminalEngine()

    var body: some View {
        ZStack {
            LiquidBackground()

            TerminalViewRepresentable(engine: engine)
                .padding()
                .background(Color.black.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 20)
        }
        .onAppear {
            engine.start()
        }
    }
}

#Preview {
    MainView()
}

