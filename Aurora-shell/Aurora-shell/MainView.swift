import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: ShellViewModel
    @State private var currentInput: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(viewModel.lines) { line in
                            HStack(alignment: .top, spacing: 4) {

                                if let prompt = line.prompt {
                                    Text(prompt)
                                        .foregroundStyle(.green)
                                        .font(.system(.body, design: .monospaced))
                                }

                                Text(line.text)
                                    .foregroundStyle(line.isError ? .red : .white)
                                    .font(.system(.body, design: .monospaced))
                            }
                            .id(line.id)
                        }
                    }
                    .padding(8)
                }
                .background(Color.black)

                // NEW NON‑DEPRECATED VERSION
                .onChange(of: viewModel.lines.count) {
                    if let last = viewModel.lines.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            HStack {
                Text(viewModel.prompt)
                    .foregroundStyle(.green)
                    .font(.system(.body, design: .monospaced))

                TextField("", text: $currentInput, onCommit: submit)
                    .textFieldStyle(.plain)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.white)
                    .focused($isFocused)
            }
            .padding(8)
            .background(Color.black)
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear { isFocused = true }
    }

    private func submit() {
        let trimmed = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        viewModel.handle(command: trimmed)
        currentInput = ""
    }
}

#Preview {
    MainView(viewModel: ShellViewModel())
}

