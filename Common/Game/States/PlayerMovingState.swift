//
//  PlayerMovingState.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/6/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation

class PlayerMovingState: State {
    // Singleton
    class var sharedInstance : PlayerMovingState {
        struct Static {
            static let instance : PlayerMovingState = PlayerMovingState()
        }
        return Static.instance
    }

    func enter(obj: GameObject) {
        if let player = obj as? PlayerCharacter {
            print("Entered moving state")
            player.changeAnimationState(PlayerAnimationState.Walk)
        } else {
            print("wrong owner passed to state")
        }
    }
    
    func execute(obj: GameObject) {
        if let player = obj as? PlayerCharacter {
            let gameState = GameScenesManager.sharedInstance.gameState
            if (gameState == GameState.InGame) {
                let joystick:Joystick! = GameUIManager.sharedInstance.inGameMenu?.joystick
                
                if(joystick.velocity.x == 0.0 && joystick.velocity.y == 0.0 ) {
                    player.changeState(PlayerIdleState.sharedInstance)
                }
                
                
            }

        } else {
            print("wrong owner passed to state")
        }

    }
    
    func exit(obj: GameObject) {
        if let _ = obj as? PlayerCharacter {
            print("Exiting moving state")
        } else {
            print("wrong owner passed to state")
        }

    }
}
