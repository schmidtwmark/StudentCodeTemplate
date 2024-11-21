func turtleMain(console: TurtleConsole) async throws {
    let turtle = try await console.addTurtle()
    await turtle.penDown()
    await turtle.rotate(30.0)
    await turtle.forward(50)
    await turtle.arc(radius: 40.0, angle: 270.0)
    await turtle.forward(100)
    await turtle.arc(radius: 40.0, angle: 270.0)
    await turtle.forward(100)
}
