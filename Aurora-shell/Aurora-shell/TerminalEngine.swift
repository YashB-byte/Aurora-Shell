import Foundation

struct TerminalOutputLine {
    let text: String
    let isError: Bool

    init(_ text: String, isError: Bool = false) {
        self.text = text
        self.isError = isError
    }
}

final class TerminalEngine {

    func run(command: String) -> [TerminalOutputLine] {
        let parts = command.split(separator: " ").map(String.init)
        guard let cmd = parts.first else { return [] }

        let args = Array(parts.dropFirst())

        switch cmd {
        case "help":
            return help()
        case "clear":
            return [TerminalOutputLine("\u{001B}[2J\u{001B}[H")]
        case "echo":
            return [TerminalOutputLine(args.joined(separator: " "))]
        case "date":
            return [TerminalOutputLine(Self.formattedDate())]
        case "whoami":
            return [TerminalOutputLine(NSUserName())]
        case "ls":
            return ls(args: args)
        default:
            return [TerminalOutputLine("aurora-shell: command not found: \(cmd)", isError: true)]
        }
    }

    private func help() -> [TerminalOutputLine] {
        [
            TerminalOutputLine("Available commands:"),
            TerminalOutputLine("  help      - show this help"),
            TerminalOutputLine("  clear     - clear screen"),
            TerminalOutputLine("  echo ...  - print text"),
            TerminalOutputLine("  date      - show date/time"),
            TerminalOutputLine("  whoami    - show current user"),
            TerminalOutputLine("  ls [path] - list files")
        ]
    }

    private func ls(args: [String]) -> [TerminalOutputLine] {
        let fm = FileManager.default
        let path = args.first ?? fm.currentDirectoryPath

        do {
            let items = try fm.contentsOfDirectory(atPath: path)
            return items.isEmpty
                ? [TerminalOutputLine("(empty)")]
                : items.map { TerminalOutputLine($0) }
        } catch {
            return [TerminalOutputLine("ls: \(path): \(error.localizedDescription)", isError: true)]
        }
    }

    private static func formattedDate() -> String {
        let f = DateFormatter()
        f.dateStyle = .full
        f.timeStyle = .medium
        return f.string(from: Date())
    }
}
