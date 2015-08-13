//
//  Regulator.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/13/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation
import QuartzCore

/*
Use this class to regulate code flow (for an update function say)
//          Instantiate the class with the frequency you would like your code
//          section to flow (like 10 times per second) and then only allow
//          the program flow to continue if Ready() returns true
*/

class Regulator {
    var updatePeriod:Double!
    var nextUpdateTime:Double!
    
    init(numUpdatesPerSecond:Double) {
        nextUpdateTime = Double(CACurrentMediaTime())
        
        if (numUpdatesPerSecond > 0)
        {
            updatePeriod = 1000.0 / numUpdatesPerSecond
        }

        else if (numUpdatesPerSecond == 0.0)
        {
            updatePeriod = 0.0;
        }
            
        else if (numUpdatesPerSecond < 0)
        {
            updatePeriod = -1;
        }

    }
    
    //returns true if the current time exceeds m_dwNextUpdateTime
    func isReady() -> Bool
    {
        //if a regulator is instantiated with a zero freq then it goes into
        //stealth mode (doesn't regulate)
        if (updatePeriod == 0.0) {
            return true
        }
    
        //if the regulator is instantiated with a negative freq then it will
        //never allow the code to flow
        if (updatePeriod < 0) {
            return false
        }
    
        let currentTime = CACurrentMediaTime()
    
        //the number of milliseconds the update period can vary per required
        //update-step. This is here to make sure any multiple clients of this class
        //have their updates spread evenly
    
        if (currentTime >= nextUpdateTime) {
            nextUpdateTime = currentTime + updatePeriod
    
            return true;
        }
    
        return false;
    }
    
    class func randomNumberInRange(lower lower: Float, upper: Float) -> Float {
        let r = Float(arc4random()) / Float(UInt32.max)
        return (r * (upper - lower)) + lower
    }


}