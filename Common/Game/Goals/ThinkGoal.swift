//
//  ThinkGoal.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/13/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation

class ThinkGoal : CompositeGoal {
    var goalEvaluators:[GoalEvaluator] = [GoalEvaluator]()
    
    init(owner:MovingGameObject) {
        super.init(owner: owner, type: GoalType.Think)
        self.owner = owner
        self.status = Status.Inactive

        //these biases could be loaded in from a script on a per bot basis
        //but for now we'll just give them some random values
        let wanderBias:Float = 0.2
        let patrolBias:Float = 0.3
        
        goalEvaluators.append(WanderGoalEvaluator(characterBias: wanderBias))
        goalEvaluators.append(PatrolGoalEvaluator(characterBias: patrolBias))
    }
    
    override func activate() {
        status = Status.Active
    }

    
    override func process() -> Status {
        //if status is inactive call activate and set status to active
        if(status != Status.Active) {
            self.activate()
        }
        status = processSubGoals()

        return status
    }
    
    override func terminate() {
        status = Status.Inactive
    }
    
    func arbitrate() {
        var best:Float = 0.0
        var mostDesirable:GoalEvaluator!
        
        for goalEvaluator in goalEvaluators {
            let desirability = goalEvaluator.calculateDesirability(self.owner)
            print("desirability is \(desirability) for evaluator:\(goalEvaluator)")
            
            if(desirability >= best) {
                best = desirability
                mostDesirable = goalEvaluator
            }
        }
        mostDesirable.setGoal(owner)
    }
    
    func addWanderGoal() {
        if(notPresent(GoalType.Wander.rawValue)) {
            self.removeAllSubGoals()
            self.addSubGoal(WanderGoal(owner:self.owner, type:GoalType.Wander))
        }
    }
    
    func addPatrolGoal() {
        if(notPresent(GoalType.Patrol.rawValue)) {
            self.removeAllSubGoals()
            self.addSubGoal(PatrolGoal(owner:self.owner, type:GoalType.Patrol))
        }
    }
    
    func notPresent(goalType:Int) -> Bool
    {
        if (!subgoals.isEmpty()) {
            return subgoals.peek()?.type.rawValue != goalType;
        }
    
        return true;
    }

    
}