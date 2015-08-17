//
//  AttackGoal.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/13/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation

class AttackGoal : Goal {
    
    var enemy:EnemyCharacter!
    var patrolPath:Path!
    
    override init(owner:MovingGameObject, type:GoalType) {
        super.init(owner: owner, type:type)
        self.enemy = owner as? EnemyCharacter
        print("Created Attack Goal")
        self.addAttackPath()
    }
    
    override func activate() {
        print("Activating attack mode")
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
        print("Turning off attacking")
        enemy.changeAnimationState(EnemyAnimationState.Idle)

        owner.getSteering().followPathOn = false
        status = Status.Inactive
    }
    
    func addAttackPath() {
        var paths = [Vector3D]()
        
        var pt = Vector3D(x: 0.0, y:0.0, z:100.0)
        paths.append(pt)
        pt = Vector3D(x: 90.0, y:0.0, z:100.0)
        paths.append(pt)
        pt = Vector3D(x: 90.0, y:0.0, z: 20.0)
        paths.append(pt)
        pt = Vector3D(x: 0.0, y:0.0, z: 20.0)
        paths.append(pt)
        
        patrolPath = Path(looped: true, waypoints: paths)
        
        
    }

}
