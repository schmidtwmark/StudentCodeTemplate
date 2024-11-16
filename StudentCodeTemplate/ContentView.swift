//
//  ContentView.swift
//  StudentCodeTemplate
//
//  Created by Mark Schmidt on 11/14/24.
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
    
    func stop() {
        state = .cancel
        endTime = Date()
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
}


let CORNER_RADIUS = 8.0

struct ContentView: View {
    
    @StateObject var console = Console()
    @State var task: Task<Void, Never>? = nil
    @FocusState private var isTextFieldFocused: Bool
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    @State var timeString = ""

    func timeDisplay(_ start: Date, _ end: Date) -> String{
        
        let interval = end.timeIntervalSince(start)
        if interval < 1 {
            return String(format: "%.0fms", interval * 1000)
        } else {
            return String(format: "%.2fs", interval)
        }
    }
    
    var durationString: String {
        if let startTime = console.startTime,
           let endTime = console.endTime {
            return timeDisplay(startTime, endTime)
        }
        return timeString
    }

    
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Console")
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(.rect(topLeadingRadius: CORNER_RADIUS, topTrailingRadius: CORNER_RADIUS))
                Spacer()
                if console.state != .idle {
                    HStack {
                        if console.state == .running {
                            ProgressView()
                        } else {
                            Image(systemName: console.state.icon)
                        }
                        Text("\(console.state.displayString)\(durationString)")
                    }
                    .padding(5)
                    .background(console.state.color)
                    .clipShape(.rect(cornerRadius: CORNER_RADIUS))
                }
                Spacer()
            }
            Divider()
            ScrollView {
                HStack {
                    LazyVStack (alignment: .leading) {
                        ForEach(console.lines) { line in
                            switch line.content {
                            case .output(let text):
                                Text(text)
                                    .frame(width: .infinity)
                            case .input:
                                TextField("", text: $console.userInput)
                                    .onSubmit {
                                        console.submitInput(true)
                                    }
                                    .focused($isTextFieldFocused)
                            }
                        }
                    }
                    Spacer()
                }
                .padding()
            }
            .defaultScrollAnchor(.bottom)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(.rect(bottomLeadingRadius: CORNER_RADIUS, bottomTrailingRadius: CORNER_RADIUS, topTrailingRadius: CORNER_RADIUS))
            .scrollIndicators(.visible)
            Spacer(minLength: CORNER_RADIUS)
            HStack {
                Button {
                    if let task = task {
                        console.stop()
                        task.cancel()
                        withAnimation {
                            self.task = nil
                        }
                    } else {
                        print("Pressed run")
                        
                        console.clear()
                        self.task = Task {
                            console.state = .running
                            console.startTime = Date()
                            do {
                                try await main(console: console)
                                withAnimation {
                                    console.state = .success
                                    self.task = nil
                                    console.endTime = Date()
                                }
                            } catch is CancellationError {
                                // No need to do this here -- gets set on Stop
                                // This could cause weirdness
//                                console.lastRunResult = .cancel
                            } catch {
                                console.state = .failed
                                self.task = nil
                                console.endTime = Date()
                            }
                        }
                    }
                } label: {
                    Label(task == nil ? "Run" : "Stop", systemImage: task == nil ? "play" : "stop.circle")
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .fontWeight(.heavy)
                }
                .tint(task == nil ? .accentColor : .red)
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                
                if task == nil {
                    Button(role: .destructive) {
                        withAnimation {
                            console.clear()
                        }
                    } label: {
                        Label("Clear", systemImage: "trash")
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .fontWeight(.heavy)
                    }
                    .disabled(console.lines.isEmpty)
                    .frame(maxWidth: .infinity)
                }
            }
            
        }
        .onReceive(timer) { _ in
            if let start = console.startTime {
                timeString = timeDisplay(start, Date())
            }
        }
        .font(.system(.body, design: .monospaced))
        .padding()
        .task {
            console.setFocus = { focus in
                isTextFieldFocused = focus
            }
        }
    }
}

#Preview {
    ContentView()
}
