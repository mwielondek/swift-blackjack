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
            print("Press enter for new round...")
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
            // *Drum roll* - see who wins!
            handleEndRound(for: p1)
            // Clear the table at the end of turn
            p1.cards.removeAll()
            house.cards.removeAll()
        }
        
        // use an array of players to loop through for multiplayer ver.
        house.deal(2, to: p1)
        house.draw(2)
        
        loop: while readAction() == .hit {
            house.deal(1, to: p1)
            
            switch p1.points.best {
            case 21:
                print("BLACKJACK!")
                // can't get a better score, so we break
                break loop
            case 21...:
                print("Bust!")
                // player lost, so we break
                break loop
            default:
                // in any other case we iterate
                break
            }
        }
        
        // if all the players are bust, house doesn't draw
        guard !p1.isBust else { return }
        
        while !house.reachedStoppingCondition() {
            house.draw()
        }
    }
    
    //MARK: - Handle round
    /// Outcome from players' perspective
    enum Outcome {
        case win, loss, draw
    }
    
    /// Handles end of round depending on the player's points vs house's.
    func handleEndRound(for player: CanPlay) {
        var outcome: Outcome
        defer { handleOutcome(outcome, for: player) }
        
        // if house or player is bust, no point in comparing scores
        guard !house.isBust, !player.isBust else {
            outcome = player.isBust ? .loss : .win
            return
        }
        
        switch player.points.best.compare(to: house.points.best) {
        case .greater:
            outcome = .win
        case .equal:
            outcome = .draw
        case .less:
            outcome = .loss
        }
    }
    
    func handleOutcome(_ outcome: Outcome, for player: CanPlay) {
        //TODO: Implement
        switch outcome {
        case .draw:
            print("Draw!")
        case .win:
            print("Win!")
        case .loss:
            print("Loss!")
        }
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
