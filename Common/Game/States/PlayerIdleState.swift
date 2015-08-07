//
//  PlayerIdleState.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/6/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation

class PlayerIdleState: State {
    // Singleton
    class var sharedInstance : PlayerIdleState {
        struct Static {
            static let instance : PlayerIdleState = PlayerIdleState()
        }
        return Static.instance
    }

    func enter(obj: GameObject) {
        if let player = obj as? PlayerCharacter {
            print("Entered idle state")
            player.changeAnimationState(PlayerAnimationState.Idle)
        } else {
            print("wrong owner passed to state")
        }
    }
    
    func execute(obj: GameObject) {
        if let player = obj as? PlayerCharacter {
            let gameState = GameScenesManager.sharedInstance.gameState
            if (gameState == GameState.InGame) {
                let joystick:Joystick! = GameUIManager.sharedInstance.inGameMenu?.joystick
                
                if(joystick.velocity.x != 0.0 || joystick.velocity.y != 0.0 ) {
                    player.changeState(PlayerMovingState.sharedInstance)
                }
                
                
            }
        } else {
            print("wrong owner passed to state")
        }

    }
    
    func exit(obj: GameObject) {
        if let _ = obj as? PlayerCharacter {
            print("Exiting idle state")
        } else {
            print("wrong owner passed to state")
        }

    }
}