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
//            CodeEnvironmentView<TextConsole, TextConsoleView>()
            CodeEnvironmentView<TurtleConsole, TurtleConsoleView>()
        }
    }
}
