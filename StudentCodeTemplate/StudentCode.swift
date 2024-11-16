func main(console: Console) async throws {
//    try await console.write("Hello, World!\nThis is multi line text")
    
//    var output = ColoredString()
//    output += ColoredString("Hello", .green)
//    output += ColoredString(", World!", .red)
//    try await console.write(output)
    
    let input = try await console.read("Enter a number")
    let num = Int(input) ?? 0
    for i in 0...num {
        
        try await console.write("\(i) iteration")
    }
}
