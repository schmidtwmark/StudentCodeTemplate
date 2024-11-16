//
//  ColoredString.swift
//  StudentCodeTemplate
//
//  Created by Mark Schmidt on 11/15/24.
//

import SwiftUI

struct ColoredString {
    struct Substring {
        var string: String
        var color: Color
    }
    
    init() {
        substrings = []
    }
    
    init(_ string: String, _ color: Color) {
        substrings = [.init(string: string, color: color)]
    }
    
    private init(_ substrings: [Substring]){
        self.substrings = substrings
    }
    
    var substrings: [Substring]
    
    var attributedString: AttributedString {
        return substrings.reduce(into: AttributedString()) { output, substring in
            var attributedSubstring = AttributedString(substring.string)
            attributedSubstring.foregroundColor = substring.color
            output.append(attributedSubstring)
        }
        
    }
    
    var string: String {
        return substrings.reduce("") { $0 + $1.string }
    }
    
    static func += (lhs: inout ColoredString, rhs: ColoredString) {
        lhs.substrings.append(contentsOf: rhs.substrings)
    }
    
    static func += (lhs: inout ColoredString, rhs: String) {
        if var last = lhs.substrings.last {
            last.string += rhs
        } else {
            lhs.substrings.append(.init(string: rhs, color: .primary))
        }
    }
    
    static func + (lhs: ColoredString, rhs: ColoredString) -> ColoredString {
        return .init(lhs.substrings + rhs.substrings)
    }
    
    static func + (lhs: ColoredString, rhs: String) -> ColoredString {
        if var last = lhs.substrings.last {
            last.string += rhs
            return lhs
        } else {
            return .init(rhs, .primary)
        }
        
    }
}

extension String {
    func colored(_ color: Color) -> ColoredString {
        return ColoredString(self, color)
    }
    
    static func += (lhs: inout String, rhs: ColoredString) {
        if lhs.isEmpty {
            lhs = rhs.string
        }
    }
    
    static func + (lhs: String, rhs: ColoredString) -> ColoredString {
        if var first = rhs.substrings.first {
            first.string = lhs + first.string
            return rhs
        } else {
            return .init(lhs, .primary)
        }
    }
}
