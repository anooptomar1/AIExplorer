//
//  StateMachine.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/6/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation

class StateMachine {
    var owner:GameObject!
    var currentState:State!
    var previousState:State!
    // this state logic is called everytime FSM is updated
    var globalState:State!
    
    init(owner:GameObject) {
        self.owner = owner
        currentState = nil
        previousState = nil
        globalState = nil
    }
    
    func setCurrentState(state:State) {
        currentState = state
    }
    
    func setPreviousState(state:State) {
        previousState = state
    }
    
    func setGlobalState(state:State) {
        globalState = state
    }
    
    //call to update FSM
    func update() {
        if(globalState != nil) {
            globalState.execute(owner)
        }
        
        if(currentState != nil) {
            currentState.execute(owner)
        }
    }
    
    func changeState(newState:State) {
        previousState = currentState
        
        currentState.exit(owner)
        
        currentState = newState
        
        currentState.enter(owner)
        
    }
    
    func returnToPreviousState() {
        self.changeState(previousState)
    }
}