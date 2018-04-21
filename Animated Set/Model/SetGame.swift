//
//  SetGame.swift
//  Animated Set
//
//  Created by Oleg Gnashuk on 2/4/18.
//  Copyright © 2018 Oleg Gnashuk. All rights reserved.
//

import Foundation

struct SetGame {
    
    private let interval: TimeInterval = 60
    
    var hintCards = [Int]()
    
    private(set) var deck = [Card]()
    private(set) var score = 0
    
    private(set) var cardsOnTable = [Card]()
    var lastDealtCards = [Card]()
    private var selectedCards = [Card]()
    
    private var lastMatchDate = Date()
    
    init() {
        initializeDeck()
        dealStartingCards()
    }
    
    mutating func chooseCard(at index: Int) {
        let chosenCard = cardsOnTable[index]
        if selectedCards.contains(chosenCard) {
            selectedCards.remove(at: selectedCards.index(of: chosenCard)!)
        } else {
            selectedCards.append(chosenCard)
            if selectedCards.count == 3 {
                if isSet(on: selectedCards) {
                    selectedCards.forEach { (card) in
                        let index = cardsOnTable.index(of: card)!
                        if deck.count > 0 {
                            cardsOnTable[index] = deck.remove(at: deck.count.arc4random)
                            lastDealtCards.append(cardsOnTable[index])
                        } else {
                            cardsOnTable.remove(at: index)
                        }
                    }
                    score += Date().timeIntervalSince(lastMatchDate) < interval ? 2 : 1
                } else {
                    score -= 1
                }
                selectedCards.removeAll()
            }
        }
    }
    
    mutating func shuffle() {
        for _ in 0..<cardsOnTable.count {
            cardsOnTable.append(cardsOnTable.remove(at: cardsOnTable.count.arc4random))
        }
    }
    
    mutating func unselectAll() {
        selectedCards.removeAll()
    }
    
    mutating func draw() {
        hint()
        if hintCards.count > 0 && deck.count > 0 {
            score -= 1
        }
        putCardsOnTable()
    }
    
    mutating func putCardsOnTable() {
        for _ in 0..<3 {
            if deck.count > 0 {
                cardsOnTable.append(deck.remove(at: deck.count.arc4random))
            }
        }
    }
    
    mutating func hint() {
        hintCards.removeAll()
        for i in 0..<cardsOnTable.count {
            for j in (i + 1)..<cardsOnTable.count {
                for k in (j + 1)..<cardsOnTable.count {
                    let hints = [cardsOnTable[i], cardsOnTable[j], cardsOnTable[k]]
                    if isSet(on: hints) {
                        hintCards += [i, j, k]
                        return
                    }
                }
            }
        }
    }
    
    private mutating func initializeDeck() {
        Card.Color.all.forEach { (color) in
            Card.Number.all.forEach { (number) in
                Card.Shape.all.forEach { (shape) in
                    Card.Fill.all.forEach { (fill) in
                        deck.append(Card(color, number, shape, fill))
                    }
                }
            }
        }
    }
    
    private mutating func dealStartingCards() {
        for _ in 0..<4 {
            putCardsOnTable()
        }
    }
    
    private func isSet(on cards: [Card]) -> Bool {
        let uniqueColors = Set(cards.map {$0.color } ).count
        let uniqueNumbers = Set(cards.map {$0.number} ).count
        let uniqueShapes = Set(cards.map {$0.shape} ).count
        let uniqueFills = Set(cards.map {$0.fill} ).count

        return uniqueColors != 2 && uniqueNumbers != 2 && uniqueShapes != 2 && uniqueFills != 2
//        return true
    }
    
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}

