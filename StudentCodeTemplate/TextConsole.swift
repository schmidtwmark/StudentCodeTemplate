//
//  Console.swift
//  StudentCodeTemplate
//
//  Created by Mark Schmidt on 11/16/24.
//

import SwiftUI
import Combine
import DequeModule

let MAX_LINES = 100

@MainActor
class TextConsole: BaseConsole<TextConsole>, Console {
    required init(colorScheme: ColorScheme) {
        super.init(mainFunction: main)
    }
    
    struct Line : Identifiable {
        
        enum LineContent {
            case output(AttributedString)
            case input
        }
        var id = UUID()
        var content: LineContent
    }
    
    var setFocus: ((Bool) -> Void)? = nil
    
    @Published var lines: Deque<Line> = Deque()
    @Published var userInput = ""
    
    private var continuation: CheckedContinuation<String?, Never>?
    
    private func append(_ line: Line) throws {
        if state == .running {
            if lines.count >= MAX_LINES {
                lines.removeFirst()
            }
            lines.append(line)
        } else {
            throw CancellationError()
        }
    }

    func write(_ line: String) throws {
        try append(Line(content: .output(.init(stringLiteral: line))))
    }
    
    func write(_ colored: ColoredString) throws {
        try append(Line(content: .output(colored.attributedString)))
    }
    
    func read(_ prompt: String) async throws -> String {
        try append(Line(content: .output(.init(stringLiteral: prompt))))
        try append(Line(content: .input))
        setFocus?(true)
        
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
        } ?? ""
    }
               
    func submitInput(_ resume: Bool) {
        guard let continuation = continuation else { return }
        if lines.count > 0 {
            lines[lines.count - 1].content = .output(.init(stringLiteral: userInput))
        }
        if resume {
            continuation.resume(returning: userInput)
        }
        userInput = ""
        self.continuation = nil // Reset continuation
    }
    
    
    override func stop() {
        super.stop()
        submitInput(false)
    }
    
    override func clear() {
        super.clear()
        lines = []
        userInput = ""
        continuation = nil
    }
    
    
    var disableClear: Bool {
        lines.isEmpty
    }
    var title: String { "Console" }
}
