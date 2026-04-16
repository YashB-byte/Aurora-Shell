#if !os(macOS)
import Foundation

final class SandboxedShell: ObservableObject {
    @Published var output: [String] = []
    @Published var cwd: URL

    private let root: URL

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        root = docs.appendingPathComponent("aurora-shell")
        cwd = root
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        output.append("Aurora Shell \u{26A1} Sandboxed FS — type 'help' for commands")
        output.append("cwd: \(root.path)")
    }

    func run(_ input: String) {
        let parts = input.trimmingCharacters(in: .whitespaces).components(separatedBy: " ").filter { !$0.isEmpty }
        guard let cmd = parts.first else { return }
        let args = Array(parts.dropFirst())
        output.append("% \(input)")

        switch cmd {
        case "help":
            output.append("ls  cd  mkdir  rm  touch  pwd  clear  cat  echo")
        case "pwd":
            output.append(cwd.path)
        case "ls":
            let target = resolve(args.first)
            let items = (try? FileManager.default.contentsOfDirectory(atPath: target.path)) ?? []
            output.append(items.isEmpty ? "(empty)" : items.joined(separator: "  "))
        case "mkdir":
            guard let name = args.first else { output.append("mkdir: missing name"); return }
            let url = resolve(name)
            do { try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true) }
            catch { output.append("mkdir: \(error.localizedDescription)") }
        case "touch":
            guard let name = args.first else { output.append("touch: missing name"); return }
            FileManager.default.createFile(atPath: resolve(name).path, contents: nil)
        case "rm":
            guard let name = args.first else { output.append("rm: missing name"); return }
            do { try FileManager.default.removeItem(at: resolve(name)) }
            catch { output.append("rm: \(error.localizedDescription)") }
        case "cd":
            let target = resolve(args.first ?? "")
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: target.path, isDirectory: &isDir), isDir.boolValue {
                cwd = target
            } else {
                output.append("cd: no such directory")
            }
        case "cat":
            guard let name = args.first else { output.append("cat: missing name"); return }
            if let text = try? String(contentsOf: resolve(name)) { output.append(text) }
            else { output.append("cat: cannot read file") }
        case "echo":
            output.append(args.joined(separator: " "))
        case "clear":
            output.removeAll()
        default:
            output.append("\(cmd): command not found — this is a sandboxed shell")
        }
    }

    private func resolve(_ path: String?) -> URL {
        guard let path, !path.isEmpty else { return cwd }
        if path == ".." { return cwd.deletingLastPathComponent().path.hasPrefix(root.path) ? cwd.deletingLastPathComponent() : root }
        if path.hasPrefix("/") { return root.appendingPathComponent(String(path.dropFirst())) }
        return cwd.appendingPathComponent(path)
    }
}
#endif
