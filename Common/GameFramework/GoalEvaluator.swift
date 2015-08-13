//
//  GoalEvaluator.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/13/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation

/*
class template that defines an interface for objects that are
able to evaluate the desirability of a specific strategy level goal
*/

protocol GoalEvaluator {
    var characterBias:Float { get }
    
    //returns a score between 0 and 1 representing the desirability of the
    //strategy the concrete subclass represents
    func calculateDesirability(pBot:MovingGameObject) -> Float
    
    //adds the appropriate goal to the given bot's brain
    func setGoal(pBot:MovingGameObject)

    
}