func turtleMain(console: TurtleConsole) async throws {
    let turtle = try await console.addTurtle()
    await turtle.rotate(45)
    await turtle.penDown()
    await turtle.forward(100)
    await turtle.setColor(.red)
    await turtle.rotate(-90)
    await turtle.forward(200)
    
    
}
