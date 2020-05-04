//
//  Player.swift
//  Blackjack
//
//  Created by Milosz Wielondek on 04/05/2020.
//  Copyright © 2020 Seeking Clarity. All rights reserved.
//

protocol CanPlay: HasCards, CustomStringConvertible {
    var name: String { get }
    var cash: Double { get set }
}

protocol HasCards: AnyObject {
    var cards: Cards { get set }
}

extension HasCards {
    var points: Points {
        let pointValues = cards.map { $0.pointValue }
        return Points(pointsArray: pointValues)
    }
    
    func receive(cards: [Card]) {
        self.cards.append(contentsOf: cards)
    }
}

extension CanPlay {
    var description: String {
        return "\(name) (holds \(cards.count) cards)"
    }
}

class Player: CanPlay {
    var name: String = "Player"
    var cash: Double = 100
    var cards: Cards = []
}

@propertyWrapper
struct InfiniteDeck {
    var deck: Cards = []
    var wrappedValue: Cards {
        mutating get {
            if deck.isEmpty {
                deck = Game.createNewDeck().shuffled()
            }
            return deck
        }
        set {
            deck = newValue
        }
    }
}

class Dealer: CanPlay {
    var name: String = "The house"
    var cash: Double = 10000
    var cards: Cards = []
    @InfiniteDeck var deck: Cards
    
    init() {}
    
    func deal(_ amount: Int, to player: CanPlay) {
        print("* Dealing \(amount) cards to \(player.name)")
        
        let drawn = Array(deck.prefix(upTo: amount))
        player.receive(cards: drawn)
        deck.removeFirst(amount)
        
        for card in drawn {
            print("Got \(card)")
        }
        
        let points = player.points.valid
        var stringReprOfPoint: String
        if points.isEmpty {
            stringReprOfPoint = "more than 21 points"
        } else {
            stringReprOfPoint = points.description
        }
        print("\(player.name) now holds \(player.cards.count) cards worth \(stringReprOfPoint)")
    }
    
    func draw(_ amount: Int = 1) {
        deal(amount, to: self)
    }
    
    func reachedStoppingCondition() -> Bool {
        guard !cards.isEmpty else { return false }
        if points.valid.isEmpty {
            // has cards on hand, but no valid combinations - bust
            return true
        } else {
            return points.best! >= 17
        }
    }
    
}