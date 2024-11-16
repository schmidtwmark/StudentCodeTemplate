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
protocol Console : ObservableObject {
    
    init()
    
    func write(_ line: String) async throws
    
    func write(_ colored: ColoredString) async throws
    
    func read(_ prompt: String) async throws -> String
    
    func tick()
    
    var state: RunState { get }
    
    var durationString: String { get }
    
    func start()
    
    func stop()
    
    func clear()
    
    var disableClear: Bool { get }
}
