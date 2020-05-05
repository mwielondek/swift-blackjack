//
//  Card.swift
//  Blackjack
//
//  Created by Milosz Wielondek on 04/05/2020.
//  Copyright © 2020 Seeking Clarity. All rights reserved.
//

//MARK: - Card
struct Card {
    let rank: Rank
    let suit: Suit
}

extension Card {
    enum Rank: Int, CaseIterable {
        case two = 2, three, four, five, six, seven, eight, nine, ten
        case jack, queen, king, ace
    }
    enum Suit: Character, CaseIterable {
        case spades = "♠", hearts = "♡", diamonds = "♢", clubs = "♣"
    }
}

extension Card: CustomStringConvertible {
    var description: String {
        let r = String(describing: rank).capitalized
        let s = suit.rawValue
        return "\(r) \(s)"
    }
}

extension Card {
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

typealias Cards = [Card]

//MARK: - PointValues
typealias PointValues = (Int, Int?)
struct Points {
    private var pointCombinations: [[Int]]
    
    /// All valid point combinations
    var valid: [Int] {
        pointSumCombinations.filter{ $0 <= 21 }.sorted(by: >)
    }
    /// The best valid point combination. If none exists returns the combination closest to 21.
    var best: Int {
        if let bestValid = valid.first {
            return bestValid
        }
        // the smallest combination will be closest to 21, since
        // if there exist no valid combinations, this means that
        // all combinations are >21 (or that player holds no cards).
        return pointSumCombinations.sorted(by: <).first ?? 0
    }
    
    init(pointsArray: [PointValues]) {
        pointCombinations = Points.constructCombinations(from: pointsArray)
    }
    init() {
        self.init(pointsArray: [])
    }
}

extension Points {
    private var pointSumCombinations: [Int] {
        pointCombinations.reduce([]) {
            // we sum each inner array
            $0 + [$1.reduce(0, +)]
        }
    }
    
    /**
    Constructs all possible point counting combinations, given that aces can be counted as 11 or 1.
     - parameter points: an array of `PointValues`
     */
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
}

//MARK: - Deck
extension Game {
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
}

/// An array of 52 standard playing cards that automatically refills and shuffles when empty.
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
