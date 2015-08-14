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
    var obstacles:[String: GameObject]!
    var hideTarget:MovingGameObject!
    var path:Path!
    
    var seekOn:Bool = false
    var fleeOn:Bool = false
    var pursueOn:Bool = false
    var evadeOn:Bool = false
    var wanderOn:Bool = false
    var avoidWallOn:Bool = false
    var avoidCollisionOn:Bool = false
    var hideOn = false
    var followPathOn = false
    
    
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
        if(avoidCollisionOn) {
            let force = self.collisionAvoidance(obstacles)
            steeringForce.x = steeringForce.x + force.x
            steeringForce.z = steeringForce.z + force.z
        }
        if(hideOn) {
            let force = self.hideFromTarget(hideTarget, gameObjects: obstacles)
            steeringForce.x = steeringForce.x + force.x
            steeringForce.z = steeringForce.z + force.z
        }
        if(followPathOn) {
            let force = self.followPath()
            steeringForce.x = steeringForce.x + force.x
            steeringForce.z = steeringForce.z + force.z
        }
        
        return steeringForce
    }
    
    func seek(target:SCNVector3) -> Vector2D {
        let vectorFromAgentToTarget = SCNVector3(x: target.x - obj.getPosition().x, y: target.y - obj.getPosition().y, z: target.z - obj.getPosition().z)
        let vec = vectorFromAgentToTarget.vector3DFromSCNVector3()
        let normalizedSeekTarget = vec.normalized()
        
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
        let vec = vectorFromAgentToTarget.vector3DFromSCNVector3()
        let normalizedSeekTarget = vec.normalized()
        
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
        let vec = vectorToTarget.vector3DFromSCNVector3()
        let dist = vec.length()
        
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
    
    func avoidCollisionsOn(gameObjects: [String: GameObject]) {
        avoidCollisionOn = true
        self.obstacles = gameObjects
    }
    
    func collisionAvoidance(gameObjects:[String: GameObject]) -> Vector2D {
        let MAX_SEE_AHEAD:Float = 40.0
        let MAX_AVOID_FORCE:Float = 40.0
        var velocity = obj.getVelocity()
        velocity = velocity.normalized()
        let vel = velocity.scaleBy(MAX_SEE_AHEAD)
        let vel2 = velocity.scaleBy(MAX_SEE_AHEAD*0.5)
        
        let ahead = Vector2D(x:Float(obj.getPosition().x) + vel.x, z: Float(obj.getPosition().z) + vel.z) // calculate the ahead vector
        let ahead2 = Vector2D(x:Float(obj.getPosition().x) + vel2.x, z: Float(obj.getPosition().z) + vel2.z)
        
        var avoidance = Vector2D(x:0.0, z:0.0)
        
        if let mostThreatening = findMostThreateningObstacle(ahead, ahead2: ahead2, gameObjects:gameObjects) {
            avoidance.x = ahead.x - Float(mostThreatening.getObjectPosition().x)
            avoidance.z = ahead.z - Float(mostThreatening.getObjectPosition().z)
            
            avoidance = avoidance.normalized()
            avoidance = avoidance.scaleBy(MAX_AVOID_FORCE)
        } else {
            avoidance = avoidance.scaleBy(0); // nullify the avoidance force
        }
        
        return avoidance
    }
    
    func findMostThreateningObstacle(ahead:Vector2D, ahead2:Vector2D, gameObjects:[String: GameObject]) -> GameObject! {
        var mostThreatening :GameObject!
        
        for (name, obstacle) in gameObjects {
            if(name != obj.getID()) {
                //ignore self
            
                //print("Checking obstacle \(name)")

                let objPos = Vector2D(x:Float(obj.getPosition().x), z: Float(obj.getPosition().z))
                let obstaclePos = Vector2D(x: Float(obstacle.getObjectPosition().x), z: Float(obstacle.getObjectPosition().z))
                let collision :Bool = lineIntersectsCircle(ahead, ahead2: ahead2, obstacle: obstacle);
            
                // "position" is the character's current position
                if(collision == true) {
                    if(mostThreatening == nil) {
                        mostThreatening = obstacle
                    } else {
                        let pos = Vector2D(x: Float(mostThreatening.getObjectPosition().x),
                                   z: Float(mostThreatening.getObjectPosition().z))
                        if (distance(objPos, b: obstaclePos) < distance(objPos, b:pos)) {
                            mostThreatening = obstacle;
                        }
                    }
                }
            }
        }
        if(mostThreatening != nil) {
            print("Found most threatening obstacle \(mostThreatening.getID())")
        }
        return mostThreatening;

    }
    
    private func distance(a :Vector2D, b :Vector2D) -> Float {
        return sqrt((a.x - b.x) * (a.x - b.x)  + (a.z - b.z) * (a.z - b.z))
    }
    
    private func lineIntersectsCircle(ahead :Vector2D, ahead2 :Vector2D, obstacle :GameObject) -> Bool {
        let obPos = Vector2D(x: Float(obstacle.getObjectPosition().x), z: Float(obstacle.getObjectPosition().z))
        return distance(obPos, b: ahead) <= obstacle.getBoundingRadius() || distance(obPos, b:ahead2) <= obstacle.getBoundingRadius()
    }
    
    func getRandomClamped() -> Float {
        let v1 = Float(arc4random()) /  Float(UInt32.max)
        let v2 = Float(arc4random()) /  Float(UInt32.max)
        return v1 - v2
    }

    
    func hideOn(target:MovingGameObject, gameObjects: [String: GameObject]) {
        self.hideOn = true
        self.hideTarget = target
        self.obstacles = gameObjects
    }
    
    func hideFromTarget(target:MovingGameObject,gameObjects: [String: GameObject]) -> Vector2D {
        var distanceToClosest:Float = MAXFLOAT
        var bestHidingSpot = Vector2D(x:0.0, z:0.0)
        
        for (_, obstacle) in obstacles {
            
            let ax = Float(obstacle.getObjectPosition().x)
            let az = Float(obstacle.getObjectPosition().z)
            let vec1 = Vector2D(x:ax, z:az)
            let bx = Float(target.getPosition().x)
            let bz = Float(target.getPosition().z)
            let v2 = Vector2D(x:bx, z:bz)
            
            
            let hidingSpot = self.getHidingPosition(vec1, obstacleRadius: obstacle.getBoundingRadius(), targetPosition: v2)
            let c = hidingSpot.x - Float(obj.getPosition().x)
            let d = hidingSpot.z - Float(obj.getPosition().z)
            
            let distSquared = c * c + d * d
            
            if(distSquared < distanceToClosest) {
                distanceToClosest = distSquared
                bestHidingSpot = hidingSpot
            }
            
        }
        
        if(distanceToClosest == MAXFLOAT) {
            return evade(target)
        }
        
        // else using arrive to the hiding spot
        return arrive(SCNVector3(x: GFloat(bestHidingSpot.x), y: 0, z: GFloat(bestHidingSpot.z)), deceleration: Deceleration.fast)
    }
    
    func getHidingPosition(obstaclePosition:Vector2D, obstacleRadius:Float, targetPosition:Vector2D) -> Vector2D {
        let distanceFromBoundary:Float = 10.0
        
        let distAway = obstacleRadius + distanceFromBoundary
        
        var toOb = Vector2D(x:obstaclePosition.x - targetPosition.x, z: obstaclePosition.z - targetPosition.z)
        toOb = toOb.normalized()
        
        //scale to size and add to obstacle's position
        toOb = toOb.scaleBy(distAway)
        return Vector2D(x: toOb.x + obstaclePosition.x, z: toOb.z + obstaclePosition.z)
    }
    
    func followPathOn(path:Path) {
        self.followPathOn = true
        self.path = path
    }
    
    func followPath() -> Vector2D {
        let waypointDistanceSquared:Float = 25.0
        let dx = path.currentWayPoint.x - Float(obj.getPosition().x)
        let dz = path.currentWayPoint.z - Float(obj.getPosition().z)
        
        let distSquared = dx*dx + dz*dz
        
        if(distSquared < waypointDistanceSquared) {
            path.setNextWayPoint()
        }
        
        let vec = SCNVector3(x: GFloat(path.currentWayPoint.x), y: 0, z: GFloat(path.currentWayPoint.z))
        if(path.finished() == true) {
            return seek(vec)
        } else {
            return arrive(vec, deceleration: Deceleration.normal)
        }
    }
}