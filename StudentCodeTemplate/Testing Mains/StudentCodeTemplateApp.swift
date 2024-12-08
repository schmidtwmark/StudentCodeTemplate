//
//  StudentCodeTemplateApp.swift
//  StudentCodeTemplate
//
//  Created by Mark Schmidt on 11/14/24.
//

import SwiftUI

@main
struct StudentCodeTemplateApp: App {
    var body: some Scene {
        WindowGroup {
//            ContentView<TextConsole, TextConsoleView>()
            ContentView<TurtleConsole, TurtleConsoleView>()
        }
    }
}
