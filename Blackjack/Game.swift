//
//  Game.swift
//  Blackjack
//
//  Created by Milosz Wielondek on 04/05/2020.
//  Copyright © 2020 Seeking Clarity. All rights reserved.
//

class Game {
    let p1 = Player()
    let house = Dealer()
}

extension Game {
    func play() {
        // add betting rules here, where running out of
        // cash would be the stopping cond.
        while true {
            print("-- NEW ROUND --")
            playRound()
            print("Press any key for new round...")
            _ = readLine()
        }
    }
    
    func playRound() {
        /*
         Logic in short:
          1. players draw two cards
          2. house draws two cards
          3. players choose stand or hit
          4. house draws until stopping condition
          5. check who won
        */
        
        defer {
            // Clear the table at the end of turn
            p1.cards.removeAll()
            house.cards.removeAll()
        }
        
        
        // use an array of players to loop through for multiplayer ver.
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
    
    //MARK: - Handle round
    func handleLostRound(losing player: CanPlay) {
        print("Lost!")
    }
    
    func handleWonRound(winning player: CanPlay) {
        print("Won!")
    }
    
    func handleDraw(drawing player: CanPlay) {
        print("Draw!")
    }
}

//MARK: - Input/Action
extension Game {
    enum Action {
        case hit, stand
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

//MARK: - Other
private extension Int {
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
