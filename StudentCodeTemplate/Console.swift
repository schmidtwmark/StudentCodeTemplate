//
//  Console.swift
//  StudentCodeTemplate
//
//  Created by Mark Schmidt on 11/16/24.
//

import SwiftUI

func timeDisplay(_ start: Date, _ end: Date) -> String{
    
    let interval = end.timeIntervalSince(start)
    if interval < 1 {
        return String(format: "%.0fms", interval * 1000)
    } else {
        return String(format: "%.2fs", interval)
    }
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

@MainActor
protocol Console : ObservableObject {
    
    init(colorScheme: ColorScheme)
    
    func tick()
    
    var state: RunState { get }
    
    var durationString: String { get }
    
    func start()
    
    func stop()
    
    func clear()
    
    var disableClear: Bool { get }
    
    var title: String { get }
}

@MainActor
class BaseConsole<C: Console> {
    @Published var state: RunState = .idle
    @Published var startTime : Date? = nil
    @Published var endTime : Date? = nil
    @Published var timeString = ""
    @Published var task: Task<Void, Never>? = nil
    
    var mainFunction: (_ console: C) async throws -> Void
    
    init(mainFunction: @escaping (_ console: C) async throws -> Void) {
        self.mainFunction = mainFunction
    }
    
    var durationString: String {
        if let startTime = startTime,
           let endTime = endTime {
            return timeDisplay(startTime, endTime)
        }
        return timeString
    }
    
    func tick() {
        if let start = startTime {
            timeString = timeDisplay(start, Date())
        }
    }
    
    func finish(_ newState: RunState) {
        state = newState
        task = nil
        endTime = Date()

    }
    
    func stop() {
        task?.cancel()
        finish(.cancel)
    }
    
    func clear() {
        startTime = nil
        endTime = nil
        state = .idle
    }
    
    func start() {
        state = .running
        startTime = Date()
        self.task = Task {
            do {
                try await mainFunction(self as! C)
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

}

protocol ConsoleView: View {
    init(console: any Console)
}
