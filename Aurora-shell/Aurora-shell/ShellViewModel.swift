// FILE: ShellViewModel.swift
import Foundation
import Combine

final class ShellViewModel: ObservableObject {
    @Published var lines: [ShellLine] = []
    @Published var prompt: String = "aurora-shell %"

    private let engine = TerminalEngine()
    private var model = ShellModel()
    private var cancellables = Set<AnyCancellable>()

    init() {
        engine.output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                self?.append(system: text)
            }
            .store(in: &cancellables)

        engine.start()
    }

    func handle(command: String) {
        append(prompt: model.prompt, text: command)
        engine.send(command)
    }

    private func append(prompt: String? = nil, text: String, isError: Bool = false) {
        let line = ShellLine(prompt: prompt, text: text, isError: isError)
        model.lines.append(line)
        lines = model.lines
    }

    private func append(system text: String, isError: Bool = false) {
        append(prompt: nil, text: text, isError: isError)
    }
}

