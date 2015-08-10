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
    var targetNode:SCNNode!
    var targetMovingObject:MovingGameObject!
    var wanderTarget:Vector2D = Vector2D(x:0.0, z:0.0)
    var wallTarget:SCNNode!

    
    var seekOn:Bool = false
    var fleeOn:Bool = false
    var pursueOn:Bool = false
    var evadeOn:Bool = false
    var wanderOn:Bool = false
    var avoidWallOn:Bool = false
    
    
    init(obj:MovingGameObject, target:SCNNode) {
        self.obj = obj
        self.targetNode = target
    }
    
    func calculate() -> Vector2D {
        let steeringForce = Vector2D(x:0.0, z:0.0)
        if(seekOn) {
            let force = self.seek(targetNode.position)
            steeringForce.x = steeringForce.x + force.x
            steeringForce.z = steeringForce.z + force.z
        }
        if(fleeOn) {
            let force = self.flee(targetNode.position)
            steeringForce.x = steeringForce.x + force.x
            steeringForce.z = steeringForce.z + force.z
        }
        if(pursueOn) {
            let force = self.pursue(targetMovingObject)
            steeringForce.x = steeringForce.x + force.x
            steeringForce.z = steeringForce.z + force.z
        }
        if(evadeOn) {
            let force = self.evade(targetMovingObject)
            steeringForce.x = steeringForce.x + force.x
            steeringForce.z = steeringForce.z + force.z
        }
        if(wanderOn) {
            let force = self.wander()
            steeringForce.x = steeringForce.x + force.x
            steeringForce.z = steeringForce.z + force.z
        }
        if(avoidWallOn) {
            let force = self.wallAvoidance(self.wallTarget)
            steeringForce.x = steeringForce.x + force.x
            steeringForce.z = steeringForce.z + force.z
        }
        
        return steeringForce
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
    
    func pursueTarget(evader:MovingGameObject) {
        self.pursueOn = true
        self.targetMovingObject = evader
    }
    
    func pursue(evader:MovingGameObject) -> Vector2D {
        #if os(iOS)
            let vectorToEvader = Vector2D(x: evader.getPosition().x - obj.getPosition().x,  z: evader.getPosition().z - obj.getPosition().z)
        #else
            let vectorToEvader = Vector2D(x: Float(evader.getPosition().x - obj.getPosition().x),  z: Float(evader.getPosition().z - obj.getPosition().z))
        #endif

        let relativeHeading = obj.getHeading().dot(evader.getHeading())
        
        if((vectorToEvader.dot(obj.getHeading()) > 0) && (relativeHeading < -0.95)) {
            return seek(evader.getPosition())
        }
        
        let speed = obj.getMaxSpeed() + evader.getVelocity().length()
        let lookAheadTime = vectorToEvader.length() / speed
        
        #if os(iOS)
            let targetPositionVector = Vector2D(x:(evader.getPosition().x + evader.getVelocity().x * lookAheadTime), z:(evader.getPosition().z + evader.getVelocity().z * lookAheadTime))
            let targetPosition = SCNVector3Make(targetPositionVector.x, 0.0, targetPositionVector.z)

        #else
            let targetPositionVector = Vector2D(x:(Float(evader.getPosition().x) + Float(evader.getVelocity().x) * lookAheadTime), z:(Float(evader.getPosition().z) + Float(evader.getVelocity().z) * lookAheadTime))
            let targetPosition = SCNVector3Make(CGFloat(targetPositionVector.x), 0.0, CGFloat(targetPositionVector.z))

        #endif
        
        return seek(targetPosition)
    }
    
    func evadeTarget(pursuer:MovingGameObject) {
        self.evadeOn = true
        self.targetMovingObject = pursuer
    }
    
    func evade(pursuer:MovingGameObject) -> Vector2D {
        #if os(iOS)
            let vectorToPursuer = Vector2D(x: pursuer.getPosition().x - obj.getPosition().x,  z: pursuer.getPosition().z - obj.getPosition().z)
        #else
            let vectorToPursuer = Vector2D(x: Float(pursuer.getPosition().x - obj.getPosition().x),  z: Float(pursuer.getPosition().z - obj.getPosition().z))
        #endif
        
        
        let speed = obj.getMaxSpeed() + pursuer.getVelocity().length()
        let lookAheadTime = vectorToPursuer.length() / speed

        #if os(iOS)
            let targetPositionVector = Vector2D(x:(pursuer.getPosition().x + pursuer.getVelocity().x * lookAheadTime), z:(pursuer.getPosition().z + pursuer.getVelocity().z * lookAheadTime))
        
            let targetPosition = SCNVector3Make(targetPositionVector.x, 0.0, targetPositionVector.z)
        #else
            let targetPositionVector = Vector2D(x:Float(pursuer.getPosition().x) + Float(pursuer.getVelocity().x) * lookAheadTime, z:Float(pursuer.getPosition().z) + Float(pursuer.getVelocity().z) * lookAheadTime)
            
            let targetPosition = SCNVector3Make(CGFloat(targetPositionVector.x), 0.0, CGFloat(targetPositionVector.z))

        #endif
        
        return flee(targetPosition)
    }
    
    func wander() -> Vector2D {
        let wanderRadius:Float = 10.0
        let wanderDistance:Float = 5.0
        let wanderJitter:Float = 5.0
        var wanderAngle:Float = 10.0
                
        var circleCenter = obj.getVelocity()
        circleCenter = circleCenter.normalized()
        circleCenter = Vector2D(x: circleCenter.x * wanderDistance, z: circleCenter.z * wanderDistance)
        
        var displacement = Vector2D(x: 0.0, z: -1.0)
        displacement = Vector2D(x: displacement.x * wanderRadius, z: displacement.z * wanderRadius)
        
        let len:Float = displacement.length()
        displacement.x = cos(wanderAngle) * len;
        displacement.z = sin(wanderAngle) * len;
        
        wanderAngle = wanderAngle + getRandomClamped()*wanderJitter
        
        return Vector2D(x: circleCenter.x + displacement.x, z: circleCenter.z + displacement.z)
    }
    
    func avoidWall(node:SCNNode) {
        avoidWallOn = true
        wallTarget = node
    }
    
    func wallAvoidance(node:SCNNode) -> Vector2D {
        if(node.name == "LeftWall") {
            return Vector2D(x:30.0, z:0.0)
        }
        else if(node.name == "RightWall") {
            return Vector2D(x:-30.0, z:0.0)
        }
        else if(node.name == "FrontWall") {
            return Vector2D(x:0.0, z:30.0)
        } else if(node.name == "BackWall") {
            return Vector2D(x:0.0, z:-30.0)
        }
        return Vector2D(x:0.0, z:0.0)
    }
    
    func getRandomClamped() -> Float {
        let v1 = Float(arc4random()) /  Float(UInt32.max)
        let v2 = Float(arc4random()) /  Float(UInt32.max)
        return v1 - v2
    }
}