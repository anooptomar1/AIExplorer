//
//  PlayerIdleState.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/6/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation

class EnemyPatrolState: State {
    // Singleton
    class var sharedInstance : EnemyPatrolState {
        struct Static {
            static let instance : EnemyPatrolState = EnemyPatrolState()
        }
        return Static.instance
    }

    func enter(obj: GameObject) {
        if let enemy = obj as? EnemyCharacter {
            print("Entered idle state")
            enemy.changeAnimationState(EnemyAnimationState.Idle)
        } else {
            print("wrong owner passed to state")
        }
    }
    
    func execute(obj: GameObject) {
        if let enemy = obj as? EnemyCharacter {
            let gameState = GameScenesManager.sharedInstance.gameState
            if (gameState == GameState.InGame) {
                
            }
        } else {
            print("wrong owner passed to state")
        }

    }
    
    func exit(obj: GameObject) {
        if let enemy = obj as? EnemyCharacter {
            print("Exiting idle state")
        } else {
            print("wrong owner passed to state")
        }

    }
}