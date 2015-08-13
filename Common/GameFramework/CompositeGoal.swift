//
//  CompositeGoal.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/13/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation


class CompositeGoal : Goal {
    
    var subgoals:Queue<Goal> = Queue<Goal>()
    
    
    override func activate() {
            
    }
        
    override func process() -> Status {
        return Status.Completed
    }
        
    override func terminate() {
            
    }
        
    override func handleMessage(obj:GameObject, msg:Message) -> Bool {
        if (!subgoals.isEmpty())
        {
            let goal = subgoals.deQueue()
            return goal!.handleMessage(obj, msg:msg)
        }
        
        //return false if the message has not been handled
        return false
    }
        
    override func addSubGoal(goal:Goal) {
        subgoals.enQueue(goal)
    }
        
    func processSubGoals() -> Status {
        while(!subgoals.isEmpty() && ((subgoals.peek()?.status == Status.Completed) || (subgoals.peek()?.status == Status.Failed))) {
            let goal = subgoals.deQueue()
            goal?.terminate()
        }
        
        if(!subgoals.isEmpty()) {
            //grab the status of the front-most subgoal
            let goal = subgoals.peek()
            let status = goal?.process()
        
            //we have to test for the special case where the front-most subgoal
            //reports 'completed' *and* the subgoal list contains additional goals.When
            //this is the case, to ensure the parent keeps processing its subgoal list
            //we must return the 'active' status.
            if (status == Status.Completed && subgoals.size() > 1) {
                return Status.Active;
            }
        
            return status!
        }  //no more subgoals to process - return 'completed'
        else
        {
            return Status.Completed
        }

    }
    
    func removeAllSubGoals() {
        while(!subgoals.isEmpty()) {
            let goal = subgoals.deQueue()
            goal?.terminate()
            
        }
    }
    
    
}