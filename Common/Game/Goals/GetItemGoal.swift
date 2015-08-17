//
//  GetItemGoal.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/13/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation

class GetItemGoal : Goal {
    
    var enemy:EnemyCharacter!
    var patrolPath:Path!
    
    override init(owner:MovingGameObject, type:GoalType) {
        super.init(owner: owner, type:type)
        self.enemy = owner as? EnemyCharacter
        print("Created GetItem Goal")
    }
    
    override func activate() {
        print("Activating get item mode")
        let pathPlanner = enemy.getPathPlanner()
        
        //Temporary position. FIx to get position to item requested (health, weapon etc)
        let position = enemy.player.position.vector3DFromSCNVector3()
        let path = pathPlanner.createPathToPosition(position)
        for item in path {
            print("Shortest path point is \(item.x) and \(item.z)")
        }
        self.patrolPath = Path(looped: false, waypoints: path)
        
        enemy!.changeAnimationState(EnemyAnimationState.Walk)

        status = Status.Active
        owner.getSteering().followPathOn(self.patrolPath)
    }
    
    override func process() -> Status {
        //if status is inactive call activate and set status to active
        if(status != Status.Active) {
            self.activate()
        }
        
        return status
    }
    
    override func terminate() {
        print("Turning off get item mode")
        enemy.changeAnimationState(EnemyAnimationState.Idle)

        owner.getSteering().followPathOn = false
        status = Status.Inactive
    }
    
}
