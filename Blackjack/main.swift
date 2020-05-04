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
}


typealias PointValues = (Int, Int?)
struct Points {
    var valid: [Int] {
        pointSumCombinations.filter{ $0 <= 21 }.sorted(by: >)
    }
    var best: Int? {
        valid.first
    }
    
    private var pointSumCombinations: [Int] {
        pointCombinations.reduce([]) {
            // we sum each inner array
            $0 + [$1.reduce(0, +)]
        }
    }
    private var pointCombinations: [[Int]]
    
    private static func constructCombinations(from points: [PointValues]) -> [[Int]] {
        var combinations = [[Int]]()
        
        // initial comnbination
        combinations.append([0])
        
        for point in points {
            for i in combinations.indices {
                if let secondValue = point.1 {
                    let newCombination = combinations[i] + [secondValue]
                    combinations.append(newCombination)
                }
                combinations[i] += [point.0]
            }
        }
        return combinations
    }
    
    init(pointsArray: [PointValues]) {
        pointCombinations = Points.constructCombinations(from: pointsArray)
    }
    init() {
        self.init(pointsArray: [])
    }
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

struct Card: CustomStringConvertible {
    
    enum Rank: Int, CaseIterable {
        case two = 2, three, four, five, six, seven, eight, nine, ten
        case jack, queen, king, ace
    }
    enum Suit: Character, CaseIterable {
        case spades = "♠", hearts = "♡", diamonds = "♢", clubs = "♣"
    }
    
    let rank: Rank
    let suit: Suit
    
    var description: String {
        let r = String(describing: rank).capitalized
        let s = suit.rawValue
        return "\(r) \(s)"
    }
    
    var pointValue: PointValues {
        let r = rank.rawValue
        switch r {
        case 14:
            // ace is worth 10 OR 1
            return (11, 1)
        case 11...:
            // face cards are worth 10
            return (10, nil)
        default:
            // rest is worth pip value
            return (r, nil)
        }
    }
}

extension StringProtocol {
    var capitalized: String {
        prefix(1).uppercased() + dropFirst()
    }
}

extension Int {
    enum ComparisonOutcome {
        case equal, greater, less
    }
    
    func compare(to otherInt: Int) -> ComparisonOutcome {
        switch self {
        case otherInt:
            return .equal
        case ...otherInt:
            return .less
        case otherInt...:
            return .greater
        default:
            fatalError()
        }
    }
}

typealias Cards = [Card]

class Game {
    let p1 = Player()
    let house = Dealer()
    
    
    enum Action {
        case hit, stand
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
        playRound()
        
    }
    
    func playRound() {
        // players draw two cards
        // house draws two cards
        // players choose stand or hit
        // house draws until stopping cond.
        
        
        house.deal(2, to: p1)
        house.draw(2)

        while readAction() == .hit {
            house.deal(1, to: p1)
            switch p1.points.best {
            case 21:
                print("BLACKJACK!")
                // TODO check what to do
                break
            case nil:
                print("Bust!")
                handleLostRound(losing: p1)
                return
            default:
                break
            }
        }
        
        while !house.reachedStoppingCondition() {
            house.draw()
        }
        
        // Compare and see who wins
        
        // Check for bust
        guard let housePoints = house.points.best else { return handleWonRound(winning: p1)}
        guard let playerPoints = p1.points.best else { return handleLostRound(losing: p1)}
        
        // Check other cases
        switch playerPoints.compare(to: housePoints) {
        case .greater:
            handleWonRound(winning: p1)
        case .equal:
            handleDraw(drawing: p1)
        case .less:
            handleLostRound(losing: p1)
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
