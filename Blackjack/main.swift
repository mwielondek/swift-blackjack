//
//  main.swift
//  Blackjack
//
//  Created by Milosz Wielondek on 27/04/2020.
//  Copyright © 2020 Seeking Clarity. All rights reserved.
//

protocol CanPlay: HasCards {
    var name: String { get }
    var cash: Double { get set }
}

protocol HasCards {
    var cards: [Card] { get set }
    func calcTotalPointsOnHand() -> Int
}

extension HasCards {
    func calcTotalPointsOnHand() -> Int {
        // FIXME
        cards.map { $0.rank.rawValue }.reduce(.zero, +)
    }
}

struct Player: CanPlay {
    var name: String = "Player"
    var cash: Double = 100
    var cards: [Card] = []
}

struct Dealer: CanPlay {
    var name: String = "The house"
    var cash: Double = 10000
    var cards: [Card] = {
        // FIXME
        var arr = [Card]()
        for suit in Card.Suit {
            for rank in Card.Rank.Type {
                let c = Card(rank: rank, suit: suit)
                arr.append(c)
            }
        }
        return arr
    }()
    
    
}

struct Card {
    enum Rank: Int, CaseIterable {
        case two = 2, three, four, five, six, seven, eight, nine, ten
        case jack, queen, king, ace
    }
    enum Suit: String, CaseIterable {
        case spades, hearts, diamonds, clubs
    }
    
    let rank: Rank
    let suit: Suit
    
    func simpleDescription() -> String {
        let r = String(describing: rank)
        return "\(suit): \(r)"
    }
}

class Game {
    let p1 = Player()
    let house = Dealer()
    
    
    enum Action {
        case hit, stand
    }
    
    init() {
        
    }
    
    func play() {
        // players draw two cards
        // house draws two cards
        // players choose stand or hit
        // house draws until stopping cond.
        house.deal(2, to: p1)
        house.draw(2) // Implement me!
        
        // implement and TBC...
        getAction(for: p1)
        
    }
    
    func readInput() -> Action {
        var action: Action?
        
        while action == nil {
            print("Hit or stand?\n>>> ", terminator: "")
            if let input = readLine() {
                switch input {
                case let s where s.hasPrefix("h"):
                    action = Action.hit
                case let s where s.hasPrefix("s"):
                    action = Action.stand
                default:
                    print("Invalid command, try again.")
                    break
                }
            }
        }
        return action!
    }
}

func main() {
    print("Starting a new game of BlackJack...")
    let g = Game()
    g.play()
    print("Finished game.")
}

main()
