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
            print("\(enemy.name) Entering patrol state")
            enemy.changeAnimationState(EnemyAnimationState.Walk)
            let msg = Message()
            msg.sender = enemy.name
            msg.receiver = nil
            msg.messageType = "Help"
            
            NSNotificationCenter.defaultCenter().postNotificationName(enemy.notificationKey, object: msg)
        } else {
            print("wrong owner passed to state")
        }
    }
    
    func execute(obj: GameObject) {
        if let enemy = obj as? EnemyCharacter {
            let gameState = GameScenesManager.sharedInstance.gameState
            if (gameState == GameState.InGame) {
                if(enemy.canSeePlayer() == true) {
                    enemy.chasePlayer()
                }
            }
        } else {
            print("wrong owner passed to state")
        }

    }
    
    func exit(obj: GameObject) {
        if let enemy = obj as? EnemyCharacter {
            print("\(enemy.name) Exiting patrol state")
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