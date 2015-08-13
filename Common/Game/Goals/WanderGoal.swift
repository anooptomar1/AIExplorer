//
//  WanderGoal.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/13/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation

class WanderGoal : Goal {
    
    var enemy:EnemyCharacter!
    
    override init(owner:MovingGameObject, type:GoalType) {
        super.init(owner: owner, type:type)
        self.enemy = owner as? EnemyCharacter
        print("Created Wander Goal")
    }
    
    override func activate() {
        print("Activating wander")
        enemy!.changeAnimationState(EnemyAnimationState.Walk)

        status = Status.Active
        owner.getSteering().wanderOn = true
    }
    
    override func process() -> Status {
        //if status is inactive call activate and set status to active
        if(status != Status.Active) {
            self.activate()
        }
        
        return status
    }
    
    override func terminate() {
        print("Turning off wandering")
        enemy.changeAnimationState(EnemyAnimationState.Idle)

        owner.getSteering().wanderOn = false
        status = Status.Inactive
    }
}