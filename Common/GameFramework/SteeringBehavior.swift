//
//  SteeringBehavior.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/8/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import SceneKit

enum Deceleration : Int {
    case fast = 1,
    normal = 2,
    slow = 3
}

class SteeringBehavior {
    
    var obj:MovingGameObject!
    var target:SCNNode!
    
    var seekOn:Bool = false
    var fleeOn:Bool = false
    
    
    init(obj:MovingGameObject, target:SCNNode) {
        self.obj = obj
        self.target = target
    }
    
    func calculate() -> Vector2D {
        if(seekOn) {
            return self.seek(target.position)
        }
        if(fleeOn) {
            return self.flee(target.position)
        }
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
    
    func arrive(target:SCNVector3, deceleration:Deceleration) -> Vector2D {
        let vectorToTarget = SCNVector3(x: target.x - obj.getPosition().x, y: target.y - obj.getPosition().y, z: target.z - obj.getPosition().z)
        let dist = vectorToTarget.length()
        
        print("Distance to target is \(dist)")
        if(dist > 1.0) {
            let decelerationTweaker:Float = 0.5
            
            var speed = dist / (Float(deceleration.rawValue) * decelerationTweaker)
            
            speed = min(speed, obj.getMaxSpeed())
            
            #if os(iOS)
                let desiredVelocity = Vector2D(x: (vectorToTarget.x * speed) / dist, z:(vectorToTarget.z * speed) / dist)
            #else
                let desiredVelocity = Vector2D(x: (Float(vectorToTarget.x) * speed) / dist, z:(Float(vectorToTarget.z) * speed) / dist)
            #endif

            return Vector2D(x: desiredVelocity.x - obj.getVelocity().x, z: desiredVelocity.z - obj.getVelocity().z)
            
        }
        return Vector2D(x:0.0, z:0.0)
    }
}