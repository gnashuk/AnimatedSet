//
//  Card.swift
//  Set
//
//  Created by Oleg Gnashuk on 2/4/18.
//  Copyright © 2018 Oleg Gnashuk. All rights reserved.
//

import Foundation

struct Card {
    var color: Color
    var number: Number
    var shape: Shape
    var fill: Fill
    
    lazy var matrix = [color.rawValue, number.rawValue, shape.rawValue, fill.rawValue]
    
    init(_ color: Color, _ number: Number, _ shape: Shape, _ fill: Fill) {
        self.color = color
        self.number = number
        self.shape = shape
        self.fill = fill
    }
    
    enum Color: String, CustomStringConvertible {
        case color1
        case color2
        case color3
        
        static let all = [Color.color1, .color2, .color3]
        var description: String { return rawValue }
    }
    
    enum Number: Int, CustomStringConvertible {
        case number1
        case number2
        case number3

        static let all = [Number.number1, .number2, .number3]
        var description: String { return String(rawValue) }
    }
    
    enum Shape: String, CustomStringConvertible {
        case shape1
        case shape2
        case shape3
        
        static let all = [Shape.shape1, .shape2, .shape3]
        var description: String { return rawValue }
    }
    
    enum Fill: String, CustomStringConvertible {
        case fill1
        case fill2
        case fill3
        
        static let all = [Fill.fill1, .fill2, .fill3]
        var description: String { return rawValue }
    }
}

extension Card: CustomStringConvertible {
    var description: String {
        return "color: \(color), number: \(number), shape: \(shape), fill: \(fill)\n"
    }
}

extension Card: Equatable {
    static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs.color == rhs.color &&
               lhs.number == rhs.number &&
               lhs.shape == rhs.shape &&
               lhs.fill == rhs.fill
    }
}
