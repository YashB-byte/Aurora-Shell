import SwiftUI

struct TerminalView: View {
    @State private var text = "Aurora Shell\n"

    var body: some View {
        TextEditor(text: $text)
            .font(.system(.body, design: .monospaced))
            .foregroundColor(.white)
            .background(Color.clear)
    }
}

