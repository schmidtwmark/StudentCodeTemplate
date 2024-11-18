func turtleMain(console: TurtleConsole) async throws {
    let turtle = try await console.addTurtle()
    await turtle.rotate(45)
    await turtle.forward(100)
    
}
