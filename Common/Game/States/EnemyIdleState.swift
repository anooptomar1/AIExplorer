//
//  PlayerIdleState.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/6/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation

class EnemyIdleState: State {
    // Singleton
    class var sharedInstance : EnemyIdleState {
        struct Static {
            static let instance : EnemyIdleState = EnemyIdleState()
        }
        return Static.instance
    }

    func enter(obj: GameObject) {
        if let enemy = obj as? EnemyCharacter {
            print("\(enemy.name) Entered idle state")
            enemy.changeAnimationState(EnemyAnimationState.Idle)
        } else {
            print("wrong owner passed to state")
        }
    }
    
    func execute(obj: GameObject) {
        if let enemy = obj as? EnemyCharacter {
            let gameState = GameScenesManager.sharedInstance.gameState
            if (gameState == GameState.InGame) {
                enemy.changeState(EnemyPatrolState.sharedInstance)
            }
        } else {
            print("wrong owner passed to state")
        }

    }
    
    func exit(obj: GameObject) {
        if let enemy = obj as? EnemyCharacter {
            print("\(enemy.name) Exiting idle state")
        } else {
            print("wrong owner passed to state")
        }

    }
    
    func handleMessage(obj:GameObject, msg:Message) -> Bool {
        if let enemy = obj as? EnemyCharacter {
            print("\(enemy.name) received \(msg.messageType) notification from \(msg.sender)")
        }
        

        return true
    }
}