import SwiftUI
import SwiftTerm
import Combine

struct TerminalViewRepresentable: NSViewRepresentable {
    let engine: TerminalEngine

    func makeCoordinator() -> Coordinator {
        Coordinator(engine: engine)
    }

    func makeNSView(context: Context) -> TerminalView {
        let term = TerminalView(frame: .zero)

        // Correct delegate property for your SwiftTerm version
        term.terminalDelegate = context.coordinator

        // PTY → Terminal
        engine.output
            .receive(on: DispatchQueue.main)
            .sink { data in
                term.feed(byteArray: ArraySlice(data))
            }
            .store(in: &context.coordinator.cancellables)

        return term
    }

    func updateNSView(_ nsView: TerminalView, context: Context) {}

    class Coordinator: NSObject, TerminalViewDelegate {
        var cancellables = Set<AnyCancellable>()
        let engine: TerminalEngine

        init(engine: TerminalEngine) {
            self.engine = engine
        }

        // MARK: - REQUIRED METHODS (all must exist)

        // Keyboard → PTY
        func send(source: TerminalView, data: ArraySlice<UInt8>) {
            engine.sendRaw(Data(data))
        }

        // Terminal resized
        func sizeChanged(source: TerminalView, newCols: Int, newRows: Int) {}

        // Title changed
        func setTerminalTitle(source: TerminalView, title: String) {}

        // Link clicked
        func requestOpenLink(source: TerminalView, link: String, params: [String : String]) {}

        // Bell character
        func bell(source: TerminalView) {}

        // Cursor moved
        func cursorPositionChanged(source: TerminalView, position: Position) {}

        // New output printed
        func scrolled(source: TerminalView, position: Int) {}

        // Terminal closed
        func closed(source: TerminalView) {}
    }
}

