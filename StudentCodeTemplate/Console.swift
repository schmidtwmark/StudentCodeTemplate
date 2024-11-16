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
class Console: ObservableObject {
    struct Line : Identifiable {
        
        enum LineContent {
            case output(AttributedString)
            case input
        }
        var id = UUID()
        var content: LineContent
    }
    
    enum RunState {
        case idle
        case running
        case success
        case cancel
        case failed
        
        var displayString: String {
            switch self {
            case .running: return "Running for "
            case .idle: return "Idle for "
            case .success: return "Success in "
            case .cancel: return "Canceled in "
            case .failed: return "Failed in "
            }
        }
        
        var color: Color {
            switch self {
            case .running, .idle: return .gray
            case .success: return .green
            case .failed: return .red
            case .cancel: return .yellow
           }
        }
        
        var icon: String {
            switch self {
            case .running, .idle: return "circle"
            case .success: return "checkmark.circle.fill"
            case .failed, .cancel: return "xmark.circle.fill"
            }
        }
    }
    
    var setFocus: ((Bool) -> Void)? = nil
    
    @Published var lines: Deque<Line> = Deque()
    @Published var userInput = ""
    @Published var state: RunState = .idle
    @Published var startTime : Date? = nil
    @Published var endTime : Date? = nil
    @Published var timeString = ""
    @Published var task: Task<Void, Never>? = nil

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
    
    func start() {
        state = .running
        startTime = Date()
        self.task = Task {
            do {
                try await main(console: self)
                withAnimation {
                    finish(.success)
                }
            } catch is CancellationError {
                // No need to do this here -- gets set on Stop
            } catch {
                withAnimation {
                    finish(.failed)
                }
            }
        }
    }
    private func finish(_ newState: RunState) {
        state = newState
        task = nil
        endTime = Date()

    }
    
    func stop() {
        task?.cancel()
        finish(.cancel)
        submitInput(false)
    }
    
    func clear() {
        startTime = nil
        endTime = nil
        state = .idle
        lines = []
        userInput = ""
        continuation = nil
    }
    
    static func timeDisplay(_ start: Date, _ end: Date) -> String{
        
        let interval = end.timeIntervalSince(start)
        if interval < 1 {
            return String(format: "%.0fms", interval * 1000)
        } else {
            return String(format: "%.2fs", interval)
        }
    }
    
    var durationString: String {
        if let startTime = startTime,
           let endTime = endTime {
            return Console.timeDisplay(startTime, endTime)
        }
        return timeString
    }
}
