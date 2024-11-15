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
class Console: ObservableObject {
    struct Line : Identifiable {
        
        enum LineContent {
            case output(String)
            case input
        }
        var id = UUID()
        var content: LineContent
    }
    
    
    @Published var lines: Deque<Line> = Deque()
//    @Published var lines: [Line] = []
    @Published var userInput = ""
    
    private var continuation: CheckedContinuation<String?, Never>?
    
    private func append(_ line: Line) {
        if lines.count >= MAX_LINES {
            lines.removeFirst()
        }
        lines.append(line)
    }

    func print(_ line: String) async {
        append(Line(content: .output(line)))
//        try? await Task.sleep(for: .milliseconds(100))
    }
    
    
    func read(_ prompt: String) async -> String {
        append(Line(content: .output(prompt)))
        append(Line(content: .input))
        
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
        submitInput(false)
    }
    
    func clear() {
        lines = []
        userInput = ""
        continuation = nil
    }
}


struct ContentView: View {
    
    @StateObject var console: Console = Console()
    @State var task: Task<Void, Never>? = nil
    
    
    var body: some View {
        VStack {
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
                                    .border(.red)
                                    .onSubmit {
                                        console.submitInput(true)
                                    }
                            }
                        }
                    }
                    Spacer()
                }
                .padding()
            }
            .defaultScrollAnchor(.bottom)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8.0))
            .font(.system(.body, design: .monospaced))
            .scrollIndicators(.visible)
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
                            await main(console: console)
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
        .padding()
    }
}

#Preview {
    ContentView()
}
