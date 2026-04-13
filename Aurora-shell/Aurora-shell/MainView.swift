import SwiftUI

struct MainView: View {
    @StateObject private var engine = TerminalEngine()

    var body: some View {
        TerminalViewRepresentable(engine: engine)
            .background(Color.black)
            .ignoresSafeArea()
    }
}
