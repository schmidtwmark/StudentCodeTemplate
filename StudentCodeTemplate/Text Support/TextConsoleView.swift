//
//  TextConsoleView.swift
//  StudentCodeTemplate
//
//  Created by Mark Schmidt on 11/16/24.
//

import SwiftUI
import Combine

struct TextConsoleView: ConsoleView {
    init(console: any Console) {
        self.console = console as! TextConsole
    }
    
    
    @ObservedObject var console: TextConsole
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
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
        .scrollIndicators(.visible)
        .task {
            console.setFocus = { focus in
                isTextFieldFocused = focus
            }
        }
    }
    
}

#Preview {
    ContentView<TextConsole, TextConsoleView>()
}
