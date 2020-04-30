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
        print("* Dealing \(amount) cards to \(player)")
        
        let drawn = Array(deck.prefix(upTo: amount))
        player.receive(cards: drawn)
        deck.removeFirst(amount)
        
        for card in drawn {
            print("Got \(card)")
        }
        let points = player.calcTotalPointsOnHand()
        print("\(player.name) now holds cards worth \(points)")
    }
    
    func draw(_ amount: Int = 1) {
        deal(amount, to: self)
    }
    
    func reachedStoppingCondition() -> Bool {
        calcTotalPointsOnHand() >= 17
    }
    
}

struct Card: CustomStringConvertible {
    enum Rank: Int, CaseIterable {
        case two = 2, three, four, five, six, seven, eight, nine, ten
        case jack, queen, king, ace
    }
    enum Suit: String, CaseIterable {
        case spades, hearts, diamonds, clubs
    }
    
    let rank: Rank
    let suit: Suit
    
    var description: String {
        let r = String(describing: rank).capitalized
        let s = suit.rawValue.capitalized
        return "\(r) of \(s)"
    }
}

extension StringProtocol {
    var capitalized: String {
        prefix(1).uppercased() + dropFirst()
    }
}

typealias Cards = [Card]

class Game {
    let p1 = Player()
    let house = Dealer()
    
    
    enum Action {
        case hit, stand
    }
    
    enum Outcome {
        case Won(Player), Lost(Player), Draw(Player)
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
        
        
    }
    
    func playRound() -> Outcome {
        // players draw two cards
        // house draws two cards
        // players choose stand or hit
        // house draws until stopping cond.
        
        
        house.deal(2, to: p1)
        house.draw(2)

        while readAction() == .hit {
            house.deal(1, to: p1)
            switch p1.calcTotalPointsOnHand() {
            case 21...:
                print("Bust!")
                handleLostRound(losing: p1)
                return
            case 21:
                print("BLACKJACK!")
                break
            default:
                break
            }
        }
        
        while !house.reachedStoppingCondition() {
            house.draw()
        }
        
        // Compare and see who wins
        let housePoints = house.calcTotalPointsOnHand()
        let playerPoints = p1.calcTotalPointsOnHand()
        switch housePoints {
        case 21...:
            print("House went bust!")
            handleWonRound(winning: p1)
        case playerPoints:
            handleDraw(drawing: p1)
        case playerPoints...:
            handleLostRound(losing: p1)
        default:
            fatalError("Weird result!")
        }
    }
    
    
    func handleLostRound(losing player: CanPlay) {
        print("Lost!")
    }
    
    func handleWonRound(winning player: CanPlay) {
        print("Won!")
    }
    
    func handleDraw(drawing player: CanPlay) {
        print("Draw!")
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
