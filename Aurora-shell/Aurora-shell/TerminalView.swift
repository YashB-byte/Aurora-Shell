import SwiftUI
import SwiftTerm

struct TerminalView: NSViewRepresentable {
    func makeNSView(context: Context) -> TerminalTextView {
        let view = TerminalTextView(frame: .zero)

        let pty = try! PTY(
            executable: "/bin/zsh",
            args: ["-l"]
        )

        // PTY → terminal
        pty.onOutput = { data in
            view.feed(data)
        }

        // terminal → PTY
        view.onSendData = { data in
            pty.write(data)
        }

        view.pty = pty
        return view
    }

    func updateNSView(_ nsView: TerminalTextView, context: Context) {}
}

