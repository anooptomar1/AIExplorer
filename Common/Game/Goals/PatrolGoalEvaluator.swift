//
//  PatrolGoalEvaluator.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/13/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation

class PatrolGoalEvaluator : GoalEvaluator {
    var cBias : Float
    
    var characterBias : Float {
        get {
            return self.cBias
        }
    }
    
    init(characterBias:Float) {
        self.cBias = characterBias
    }
    
    //returns a score between 0 and 1 representing the desirability of the
    //strategy the concrete subclass represents
    func calculateDesirability(pBot:MovingGameObject) -> Float {
        var desirability:Float = 0.40
        
        desirability = desirability * cBias
        
        return desirability
    }
    
    //adds the appropriate goal to the given bot's brain
    func setGoal(pBot:MovingGameObject) {
        let enemy = pBot as? EnemyCharacter
        enemy?.brain.addPatrolGoal()
    }
    

}
