//
//  Card.swift
//  Blackjack
//
//  Created by Milosz Wielondek on 04/05/2020.
//  Copyright © 2020 Seeking Clarity. All rights reserved.
//

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
typealias Cards = [Card]

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

extension StringProtocol {
    var capitalized: String {
        prefix(1).uppercased() + dropFirst()
    }
}
