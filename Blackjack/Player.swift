//
//  Player.swift
//  Blackjack
//
//  Created by Milosz Wielondek on 04/05/2020.
//  Copyright © 2020 Seeking Clarity. All rights reserved.
//

//MARK: - Protocols
protocol PlayerEntity: AnyObject {
    var name: String { get }
    var cards: Cards { get set }
}

extension PlayerEntity {
    var points: Points {
        let pointValues = cards.map { $0.pointValue }
        return Points(pointsArray: pointValues)
    }
    
    var isBust: Bool {
        points.best > 21
    }
    
    func receive(card: Card) {
        self.cards.append(card)
    }
}

//MARK: - Players
class Player: PlayerEntity {
    var name: String = "Player"
    var cash: Double = 100
    var cards: Cards = []
}

class Dealer: PlayerEntity {
    var name: String = "The house"
    var cash: Double = 10000
    var cards: Cards = []
    var deck: InfiniteDeck = InfiniteDeck()
}

extension Dealer {
    /**
     Deals cards to player from dealer's deck.
     - parameters:
        - amount: number of cards
        - to: receiving player
     */
    func deal(_ amount: Int, to player: PlayerEntity) {
        print("* Dealing \(amount) cards to \(player.name)")
        
        for _ in 0..<amount {
            let drawnCard = deck.next()!
            player.receive(card: drawnCard)
            print("Got \(drawnCard)")
        }
        
        let points = player.points.valid
        var stringReprOfPoint: String
        if points.isEmpty {
            stringReprOfPoint = "\(player.points.best) points"
        } else {
            stringReprOfPoint = points.description
        }
        print("\(player.name) now holds \(player.cards.count) cards worth \(stringReprOfPoint)")
    }
    
    /// Deal cards to the dealer.
    func draw(_ amount: Int = 1) {
        deal(amount, to: self)
    }
    
    /// Should the dealer draw more cards.
    func reachedStoppingCondition() -> Bool {
        guard !cards.isEmpty else { return false }
        if points.valid.isEmpty {
            // has cards on hand, but no valid combinations - bust
            return true
        } else {
            return points.best >= 17
        }
    }
}
