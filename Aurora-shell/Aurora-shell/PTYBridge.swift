import Foundation
import Darwin

@discardableResult
func spawnShellWithPTY(shellPath: String = "/bin/zsh") -> Int32 {
    var masterFD: Int32 = -1
    let pid = forkpty(&masterFD, nil, nil, nil)
    if pid == -1 { perror("forkpty"); return -1 }
    if pid == 0 {
        // Set TERM so the shell knows it's in a real terminal
        setenv("TERM", "xterm-256color", 1)
        setenv("COLORTERM", "truecolor", 1)

        // Launch zsh as a login shell so .zshrc (and aurora theme) loads automatically
        let args: [UnsafeMutablePointer<CChar>?] = [
            strdup(shellPath),
            strdup("-l"),   // login shell → sources .zshrc → aurora theme runs
            nil
        ]
        execv(shellPath, args)
        perror("execv")
        _exit(1)
    }
    return masterFD
}
