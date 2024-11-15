//
//  StudentCode.swift
//  StudentCodeTemplate
//
//  Created by Mark Schmidt on 11/14/24.
//

import Foundation


func main(console: Console) async {
    let input = await console.read("Enter a number")
    let num = Int(input) ?? 10
    for i in 0...num {
        await console.print("\(i) iteration")
    }
//    console.print("You are in a cave do you go left or right")
//    let input = await console.read("Enter your choice: ")
//    if input == "left" {
//        console.print("argh you die")
//    } else {
//        console.print("you win!")
//    }

}
