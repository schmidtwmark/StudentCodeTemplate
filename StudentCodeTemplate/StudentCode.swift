//
//  StudentCode.swift
//  StudentCodeTemplate
//
//  Created by Mark Schmidt on 11/14/24.
//

func main(console: Console) async throws {
    let input = try await console.read("Enter a number")
    let num = Int(input) ?? 10
    for i in 0...num {
        try await console.write("\(i) iteration")
    }
//    console.print("You are in a cave do you go left or right")
//    let input = await console.read("Enter your choice: ")
//    if input == "left" {
//        console.write("argh you die")
//    } else {
//        console.write("you win!")
//    }

}
