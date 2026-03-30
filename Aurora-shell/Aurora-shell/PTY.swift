import Foundation
import Combine   // REQUIRED for ObservableObject

class PTY: ObservableObject {
    private var process: Process?
    private var outputPipe = Pipe()
    private var inputPipe = Pipe()

    @Published var output: String = ""

    func start() {
        let task = Process()
        task.launchPath = "/bin/zsh"
        task.arguments = ["-l"]

        task.standardOutput = outputPipe
        task.standardError = outputPipe
        task.standardInput = inputPipe

        // Stream output live
        outputPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if let text = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.output += text
                }
            }
        }

        task.launch()
        self.process = task
    }

    func send(_ command: String) {
        let data = (command + "\n").data(using: .utf8)!
        inputPipe.fileHandleForWriting.write(data)
    }
}

