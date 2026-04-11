import Foundation
import Combine
import Darwin

final class TerminalEngine: ObservableObject {
    private(set) var masterFD: Int32 = -1
    private var readSource: DispatchSourceRead?
    let output = PassthroughSubject<Data, Never>()

    func start() {
        masterFD = spawnShellWithPTY()
        guard masterFD >= 0 else { return }

        let flags = fcntl(masterFD, F_GETFL)
        _ = fcntl(masterFD, F_SETFL, flags | O_NONBLOCK)

        readSource = DispatchSource.makeReadSource(fileDescriptor: masterFD, queue: .global())
        readSource?.setEventHandler { [weak self] in
            guard let self else { return }
            let handle = FileHandle(fileDescriptor: self.masterFD)
            let data = handle.availableData
            if !data.isEmpty {
                self.output.send(data)
            }
        }
        readSource?.resume()
    }

    func sendRaw(_ data: Data) {
        guard masterFD >= 0 else { return }
        _ = data.withUnsafeBytes {
            write(masterFD, $0.baseAddress, data.count)
        }
    }
}

