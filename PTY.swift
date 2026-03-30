import Foundation

class PTY {
    private var process: Process?
    private var outputPipe = Pipe()

    func start() {
        let task = Process()
        task.launchPath = "/bin/zsh"
        task.arguments = ["-l"]

        task.standardOutput = outputPipe
        task.standardError = outputPipe

        task.launch()
        self.process = task
    }

    func readOutput() -> String {
        let data = outputPipe.fileHandleForReading.availableData
        return String(decoding: data, as: UTF8.self)
    }

    func send(_ command: String) {
        let inputPipe = Pipe()
        process?.standardInput = inputPipe
        inputPipe.fileHandleForWriting.write((command + "\n").data(using: .utf8)!)
    }
}

