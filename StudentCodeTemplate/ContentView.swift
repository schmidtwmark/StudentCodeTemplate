//
//  ContentView.swift
//  StudentCodeTemplate
//
//  Created by Mark Schmidt on 11/14/24.
//

import SwiftUI
import Combine


let CORNER_RADIUS = 8.0

struct ContentView: View {
    
    @StateObject var console = Console()
    @FocusState private var isTextFieldFocused: Bool
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()

    
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
                        Text("\(console.state.displayString)\(console.durationString)")
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
                    if console.state == .running {
                        withAnimation {
                            console.stop()
                        }
                    } else {
                        withAnimation {
                            console.clear()
                            console.start()
                        }
                    }
                } label: {
                    Label(console.state == .running ? "Stop" : "Run", systemImage: console.state == .running ? "stop.circle" : "play")
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .fontWeight(.heavy)
                }
                .tint(console.state == .running ? .red : .accentColor)
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                
                if console.state != .running {
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
                console.timeString = Console.timeDisplay(start, Date())
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
