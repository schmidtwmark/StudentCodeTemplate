//
//  TurtleConsoleView.swift
//  StudentCodeTemplate
//
//  Created by Mark Schmidt on 11/16/24.
//

import SwiftUI
import SpriteKit

struct TurtleConsoleView: ConsoleView {
    init(console: any Console) {
        self.console = console as! TurtleConsole
    }
    
    @ObservedObject var console: TurtleConsole
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View{
        SpriteView(scene: console.scene)
            .onChange(of: colorScheme, {
                console.updateBackground(colorScheme)
            })
    }
}

#Preview {
    ContentView<TurtleConsole, TurtleConsoleView>()
}
