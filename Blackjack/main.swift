//
//  main.swift
//  Blackjack
//
//  Created by Milosz Wielondek on 27/04/2020.
//  Copyright © 2020 Seeking Clarity. All rights reserved.
//

protocol CanPlay: HasCards, CustomStringConvertible {
    var name: String { get }
    var cash: Double { get set }
}

protocol HasCards: AnyObject {
    var cards: Cards { get set }
    func calcTotalPointsOnHand() -> Int
}

extension HasCards {
    func calcTotalPointsOnHand() -> Int {
        // FIXME
        cards.map { $0.rank.rawValue }.reduce(.zero, +)
    }
    
    func isFat() -> Bool {
        calcTotalPointsOnHand() > 21
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
                deck = Game.createNewDeck()
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
    
    func deal(_ amount: Int, to player: HasCards) {
        print("* Dealing \(amount) cards to \(player)")
        player.receive(cards: Array(deck.prefix(upTo: amount)))
        deck.removeFirst(amount)
    }
    
    func draw(_ amount: Int) {
        deal(amount, to: self)
    }
    
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

typealias Cards = [Card]

class Game {
    let p1 = Player()
    let house = Dealer()
    
    
    enum Action {
        case hit, stand
    }
    
    init() {
        
    }
    
    static func createNewDeck() -> Cards {
        var arr = [Card]()
        for suit in Card.Suit.allCases {
            for rank in Card.Rank.allCases {
                let c = Card(rank: rank, suit: suit)
                arr.append(c)
            }
        }
        return arr
    }
    
    func play() {
        // players draw two cards
        // house draws two cards
        // players choose stand or hit
        // house draws until stopping cond.
        house.deal(2, to: p1)
        house.draw(2) // Implement me!

        // implement and TBC...
        while readAction() == .hit {
            house.deal(1, to: p1)
            if p1.isFat() {
                break
            }
        }
        
    }
    
    func readAction() -> Action {
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
