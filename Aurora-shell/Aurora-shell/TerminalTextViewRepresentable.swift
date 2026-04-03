import SwiftUI

struct TerminalTextViewRepresentable: NSViewRepresentable {
    func makeNSView(context: Context) -> TerminalTextView {
        TerminalTextView()
    }

    func updateNSView(_ nsView: TerminalTextView, context: Context) {}
}

