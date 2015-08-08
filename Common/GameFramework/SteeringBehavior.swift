//
//  SteeringBehavior.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/8/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import SceneKit

class SteeringBehavior {
    
    var obj:MovingGameObject!
    
    init(obj:MovingGameObject) {
        self.obj = obj
    }
    
    func calculate() -> Vector2D {
        
        return Vector2D(x:0.0, z:0.0)
    }
    
    func seek(target:SCNVector3) -> Vector2D {
        let vectorFromAgentToTarget = SCNVector3(x: target.x - obj.getPosition().x, y: target.y - obj.getPosition().y, z: target.z - obj.getPosition().z)
        let normalizedSeekTarget = vectorFromAgentToTarget.normalized()
        
        #if os(iOS)
            let desiredVelocity = Vector2D(x:normalizedSeekTarget.x*obj.getMaxSpeed(), z:normalizedSeekTarget.z*obj.getMaxSpeed())
        #else
            let desiredVelocity = Vector2D(x:Float(normalizedSeekTarget.x)*obj.getMaxSpeed(), z:Float(normalizedSeekTarget.z)*obj.getMaxSpeed())

        #endif
        
        let seekVelocity = Vector2D(x:desiredVelocity.x - obj.getVelocity().x, z:desiredVelocity.z - obj.getVelocity().z)
        
        return seekVelocity
        
    }
    
    func flee(target:SCNVector3) -> Vector2D {
        //only flee if the target is within 'panic distance'
        let panicDistanceSquared:Float = 5.0 * 5.0
        
        let distanceSquared = (obj.getPosition().x - target.x)*(obj.getPosition().x - target.x) +
            (obj.getPosition().y - target.y)*(obj.getPosition().y - target.y) +
            (obj.getPosition().z - target.z)*(obj.getPosition().z - target.z)
        
        if(Float(distanceSquared) > panicDistanceSquared) {
            return Vector2D(x:0.0, z:0.0)
        }
        
        let vectorFromAgentToTarget = SCNVector3(x: obj.getPosition().x - target.x, y: obj.getPosition().y - target.y, z: obj.getPosition().z - target.z)
        let normalizedSeekTarget = vectorFromAgentToTarget.normalized()
        
        #if os(iOS)
            let desiredVelocity = Vector2D(x:normalizedSeekTarget.x*obj.getMaxSpeed(), z:normalizedSeekTarget.z*obj.getMaxSpeed())
            #else
            let desiredVelocity = Vector2D(x:Float(normalizedSeekTarget.x)*obj.getMaxSpeed(), z:Float(normalizedSeekTarget.z)*obj.getMaxSpeed())
            
        #endif
        
        let seekVelocity = Vector2D(x:desiredVelocity.x - obj.getVelocity().x, z:desiredVelocity.z - obj.getVelocity().z)
        
        return seekVelocity
        
    }
}