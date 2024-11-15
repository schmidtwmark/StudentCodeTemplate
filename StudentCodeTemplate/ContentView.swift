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
            case output(String)
            case input
        }
        var id = UUID()
        var content: LineContent
    }
    
    var setFocus: ((Bool) -> Void)? = nil
    
    @Published var lines: Deque<Line> = Deque()
//    @Published var lines: [Line] = []
    @Published var userInput = ""
    @Published var running = false
    
    private var continuation: CheckedContinuation<String?, Never>?
    
    private func append(_ line: Line) throws {
        if running {
            if lines.count >= MAX_LINES {
                lines.removeFirst()
            }
            lines.append(line)
        } else {
            throw CancellationError()
        }
    }

    func write(_ line: String) throws {
        try append(Line(content: .output(line)))
//        try? await Task.sleep(for: .milliseconds(100))
    }
    
    
    func read(_ prompt: String) async throws -> String {
        try append(Line(content: .output(prompt)))
        try append(Line(content: .input))
        setFocus?(true)
        
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
        } ?? ""
    }
               
    func submitInput(_ resume: Bool) {
        guard let continuation = continuation else { return }
        if lines.count > 0 {
            lines[lines.count - 1].content = .output(userInput)
        }
        if resume {
            continuation.resume(returning: userInput)
        }
        userInput = ""
        self.continuation = nil // Reset continuation
    }
    
    func stop() {
        running = false
        submitInput(false)
    }
    
    func clear() {
        lines = []
        running = false
        userInput = ""
        continuation = nil
    }
}

let CORNER_RADIUS = 8.0

struct ContentView: View {
    
    @StateObject var console = Console()
    @State var task: Task<Void, Never>? = nil
    @FocusState private var isTextFieldFocused: Bool

    
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Console")
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(.rect(topLeadingRadius: CORNER_RADIUS, topTrailingRadius: CORNER_RADIUS))
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
                        console.clear()
                        self.task = Task {
                            console.running = true
                            try? await main(console: console)
                            withAnimation {
                                self.task = nil
                            }
                        }
                    }
                } label: {
                    Label(task == nil ? "Run" : "Stop", systemImage: task == nil ? "play" : "stop.circle")
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .fontWeight(.heavy)
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                
                if task == nil {
                    Button(role: .destructive) {
                        console.clear()
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
