//
//  Goal.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/13/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation

enum Status:Int {
    case Inactive = 0,
    Active,
    Completed,
    Failed
}

enum GoalType : Int {
    case Wander = 0,
    Patrol,
    Attack,
    GetItem,
    Think
}

class Goal {
    var owner:MovingGameObject!
    var status:Status = Status.Inactive
    var type:GoalType!
    
    init(owner:MovingGameObject, type:GoalType) {
        self.owner = owner
        self.type = type
    }
    
    func activate() {
        
    }
    
    func process() -> Status {
        return status
    }
    
    func terminate() {
        
    }
    
    func handleMessage(obj:GameObject, msg:Message) -> Bool {
        return true
    }
    
    func addSubGoal(goal:Goal) {
        
    }
    
    
}