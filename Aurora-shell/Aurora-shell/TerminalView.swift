import SwiftUI

struct TerminalView: View {
    @StateObject private var pty = PTY()

    var body: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()

            TerminalTextViewRepresentable(pty: pty)
                .padding()
        }
        .onAppear {
            pty.output = "Aurora Shell v1.0\n\n"
            pty.start()
        }
    }
}

