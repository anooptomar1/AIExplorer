//
//  PatrolGoal.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/13/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation

class PatrolGoal : Goal {
    
    var enemy:EnemyCharacter!
    var patrolPath:Path!
    
    override init(owner:MovingGameObject, type:GoalType) {
        super.init(owner: owner, type:type)
        self.enemy = owner as? EnemyCharacter
        print("Created Patrol Goal")
        self.addPatrolPath()
    }
    
    override func activate() {
        print("Activating patrol")
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
        print("Turning off patrolling")
        enemy.changeAnimationState(EnemyAnimationState.Idle)

        owner.getSteering().followPathOn = false
        status = Status.Inactive
    }
    
    func addPatrolPath() {
        var paths = [Vector2D]()
        
        var pt = Vector2D(x: 0.0, z:100.0)
        paths.append(pt)
        pt = Vector2D(x: 90.0, z:100.0)
        paths.append(pt)
        pt = Vector2D(x: 90.0, z: 20.0)
        paths.append(pt)
        pt = Vector2D(x: 0.0, z: 20.0)
        paths.append(pt)
        
        patrolPath = Path(looped: true, waypoints: paths)
        
        
    }

}
