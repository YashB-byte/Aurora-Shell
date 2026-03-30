import AppKit
import SwiftUI

class TerminalTextView: NSScrollView {

    private let textView = NSTextView()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        self.documentView = textView
        self.hasVerticalScroller = true
        self.borderType = .noBorder
        self.drawsBackground = false

        textView.isEditable = false
        textView.isRichText = false
        textView.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.insertionPointColor = .white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func append(_ string: String) {
        let attr = NSAttributedString(string: string)
        textView.textStorage?.append(attr)

        textView.scrollToEndOfDocument(nil)
    }
}
