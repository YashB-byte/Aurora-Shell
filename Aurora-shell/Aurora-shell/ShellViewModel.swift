import Foundation
import Combine

final class ShellViewModel: ObservableObject {
    @Published var lines: [ShellLine] = []
    @Published var prompt: String = "aurora-shell %"

    private let engine = TerminalEngine()
    private var model = ShellModel()

    func bootstrap() {
        if lines.isEmpty {
            append(system: "Aurora-shell v0.1 • AppleOS")
            append(system: "Type 'help' to see available commands.")
        }
    }

    func handle(command: String) {
        append(prompt: model.prompt, text: command)

        let output = engine.run(command: command)
        for line in output {
            append(system: line.text, isError: line.isError)
        }
    }

    private func append(prompt: String? = nil, text: String, isError: Bool = false) {
        let line = ShellLine(prompt: prompt, text: text, isError: isError)
        model.lines.append(line)
        lines = model.lines
        self.prompt = model.prompt
    }

    private func append(system text: String, isError: Bool = false) {
        append(prompt: nil, text: text, isError: isError)
    }
}
