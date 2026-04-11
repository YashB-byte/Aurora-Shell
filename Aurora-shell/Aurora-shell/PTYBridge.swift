import Foundation
import Darwin

@discardableResult
func spawnShellWithPTY(shellPath: String = "/bin/zsh",
                       args: [String] = []) -> Int32 {
    var masterFD: Int32 = -1
    let pid = forkpty(&masterFD, nil, nil, nil)
    if pid == -1 {
        perror("forkpty")
        return -1
    }
    if pid == 0 {
        var cArgs: [UnsafeMutablePointer<CChar>?] = []
        cArgs.append(strdup(shellPath))
        for arg in args {
            cArgs.append(strdup(arg))
        }
        cArgs.append(nil)
        execv(shellPath, &cArgs)
        perror("execv")
        _exit(1)
    }
    return masterFD
}

