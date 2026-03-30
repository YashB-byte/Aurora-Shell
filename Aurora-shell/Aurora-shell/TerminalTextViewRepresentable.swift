import SwiftUI

struct TerminalTextViewRepresentable: NSViewRepresentable {
    @ObservedObject var pty: PTY

    func makeNSView(context: Context) -> TerminalTextView {
        let view = TerminalTextView()
        return view
    }

    func updateNSView(_ nsView: TerminalTextView, context: Context) {
        nsView.append(pty.output)
    }
}

