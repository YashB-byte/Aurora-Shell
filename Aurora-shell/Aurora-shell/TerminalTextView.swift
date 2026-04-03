import AppKit
import SwiftTerm

final class TerminalTextView: SwiftTerm.TerminalView {

    var pty: PTY?
    var onSendData: ((Data) -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        // Terminal → PTY
        self.getTerminal().onSendData = { [weak self] data in
            self?.onSendData?(Data(data))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// PTY → Terminal
    func feed(_ data: Data) {
        let bytes = [UInt8](data)
        self.getTerminal().feed(byteArray: bytes)
    }
}

