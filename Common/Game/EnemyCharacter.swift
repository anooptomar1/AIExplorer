//
//  EnemyCharacter.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/6/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import SceneKit
import SpriteKit

enum EnemyAnimationState : Int {
    case Die = 0,
    Run,
    Idle,
    Walk,
    Attack
}

enum EnemyStatus : Int {
    case Inactive = 0,
    Spawning,
    Alive,
    Dead
}

class EnemyCharacter : SkinnedCharacter, MovingGameObject {


    var health:Float = 100.0
    var status = EnemyStatus.Inactive

    let mass:Float = 3.0
    let maxSpeed:Float = 10.0
    let maxForce:Float = 5.0
    let maxTurnRate:Float = 0.0
    var boundingRadius:Float = 0.0
    var velocity = Vector3D(x:0.1, y:0.0, z:0.1)
    var heading = Vector3D(x:0.0, y:0.0, z:0.0)
    var side = Vector3D(x:0.0, y:0.0, z:0.0)
    
    var gameLevel:GameLevel!
    var player:PlayerCharacter!
    var stateMachine: StateMachine!
    var steering:SteeringBehavior!
    var patrolPath:Path!
    let goalArbitrationRegulator = Regulator(numUpdatesPerSecond: 4.0) // 4 updates per second
    var brain:ThinkGoal!
    var pathPlanner:PathPlanner!
    
    let assetDirectory = "art.scnassets/common/models/warrior/"
    let skeletonName = "Bip01"
    let notificationKey = "NotificationKey"
    let enemyCollisionSphereName = "EnemyCollideSphere"
    
    var currentState:EnemyAnimationState = EnemyAnimationState.Idle
    var previousState:EnemyAnimationState = EnemyAnimationState.Idle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
        
    init(characterNode:SCNNode, id:String, level:GameLevel, pathfinder:Pathfinder) {
        super.init(rootNode: characterNode)
        self.name = id
        self.gameLevel = level
        self.addCollideSphere()
        
        
        let gameObject = gameLevel.getGameObject("Player")
        self.player = gameObject as? PlayerCharacter
        print("Found player with name \(player!.getID())")
        self.steering = SteeringBehavior(obj:self, target:player!)
        
        
        //let gridPathFinder = GridPathfinder(left: -200, bottom: -200, right: 200, top: 200, grid2d: grid2d)
        //self.drawDebugPath(gridPathFinder)
        
        self.pathPlanner = PathPlanner(owner: self, pathfinder: pathfinder)
        
        self.addPatrolPath()
        self.brain = ThinkGoal(owner: self)
        self.status = EnemyStatus.Alive
        
        // Load the animations and store via a lookup table.
        self.setupIdleAnimation()
        self.setupRunAnimation()
        self.setupWalkAnimation()
        self.setupDieAnimation()
        self.setupAttackAnimation()
        
        /*
        stateMachine = StateMachine(owner: self)
        stateMachine.setCurrentState(EnemyIdleState.sharedInstance)
        stateMachine.changeState(EnemyIdleState.sharedInstance)
        */

        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "handleNotification:",
            name: notificationKey,
            object: nil)
    }
    
    func drawDebugPath(pathfinder:GridPathfinder) {
        let grids = pathfinder.getGrids()
        let level = gameLevel as? GameLevel0
        for grid in grids {
        
            let x = Float(grid.x) * Float(40) + Float(-200)
            let z = Float(grid.y) * Float(40) + Float(-200)
        
            let loc = Vector3D(x:x, y:0.0, z:z)
            let pos = loc.getSCNVector3()
            if(grid.valid == true) {
                GameUtilities.createDebugBox(level!.scene, box:SCNBox(width:5.0, height:5.0, length:5.0, chamferRadius:1.0), position: pos, color: SKColor.redColor(), rotation:SCNVector4Make(GFloat(1.0), GFloat(0.0), GFloat(0.0), GFloat(0.0)))
            } else {
                GameUtilities.createDebugBox(level!.scene, box:SCNBox(width:5.0, height:5.0, length:5.0, chamferRadius:1.0), position: pos, color: SKColor.blueColor(), rotation:SCNVector4Make(GFloat(1.0), GFloat(0.0), GFloat(0.0), GFloat(0.0)))
            }
        }
        
    }
    
    func getPathPlanner() -> PathPlanner {
        return self.pathPlanner
    }
    
    func handleNotification(notification:NSNotification) {
        let obj = notification.object as! Message
        if(self.name != obj.sender) {
            stateMachine.handleMessage(obj)
        }
    }
    
    func addCollideSphere() {
        let scale = self.getObjectScale()
        let playerBox = GameUtilities.getBoundingBox(self)
        let capRadius = scale * GFloat(playerBox.width/2.0)
        let capHeight = scale * GFloat(playerBox.height)
        self.boundingRadius = Float(capRadius)
        
        //println("enemy box width:\(playerBox.width) height:\(playerBox.height) length:\(playerBox.length)")
        
        let collideSphere = SCNNode()
        collideSphere.name = enemyCollisionSphereName + "-" + self.getID()
        collideSphere.position = SCNVector3Make(0.0, GFloat(playerBox.height/2), 0.0)
        let geo = SCNCapsule(capRadius: CGFloat(capRadius), height: CGFloat(capHeight))
        let shape2 = SCNPhysicsShape(geometry: geo, options: nil)
        collideSphere.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Kinematic, shape: shape2)
        
        // We only want to collide with walls and player. Ground collision is handled elsewhere.
        
        collideSphere.physicsBody!.collisionBitMask =
            ColliderType.FrontWall.rawValue | ColliderType.LeftWall.rawValue | ColliderType.RightWall.rawValue | ColliderType.BackWall.rawValue | ColliderType.Player.rawValue | ColliderType.Door.rawValue | ColliderType.Ground.rawValue | ColliderType.Bullet.rawValue
        
        // Put ourself into the player category so other objects can limit their scope of collision checks.
        collideSphere.physicsBody!.categoryBitMask = ColliderType.Enemy.rawValue;
        
        self.addChildNode(collideSphere)
        
    }

    func addPatrolPath() {
        var paths = [Vector3D]()
        
        var pt = Vector3D(x: 0.0, y:0.0, z:100.0)
        paths.append(pt)
        pt = Vector3D(x: 90.0, y:0.0, z:100.0)
        paths.append(pt)
        pt = Vector3D(x: 90.0, y:0.0, z: 20.0)
        paths.append(pt)
        pt = Vector3D(x: 0.0, y:0.0, z: 20.0)
        paths.append(pt)
        
        patrolPath = Path(looped: true, waypoints: paths)
        
        
    }
    
    func handleContact(node:SCNNode, gameObjects:Dictionary<String, GameObject>) {
        //print("Enemy with name \(self.name) handling contact with \(node.name)")
        self.steering.avoidWall(node)
        
        if(node.name == "BulletSphere" && status == EnemyStatus.Alive) {
            self.reduceHealth()
        }
    }
    
    func reduceHealth() {
        self.health = self.health - 10.0
        
        if(self.health <= 0.0) {
            //dead
            self.changeAnimationState(EnemyAnimationState.Die)
            self.status = EnemyStatus.Dead
        }
    }
    
    class func keyForAnimationType(animType:EnemyAnimationState) -> String!
    {
        switch (animType) {
        case .Attack:
            return "attackID"
        case .Die:
            return "DeathID"
        case .Idle:
            return "idleAnimationID"
        case .Run:
            return "RunID"
        case .Walk:
            return "WalkID"
        }
    }


    func setupIdleAnimation() {
        let fileName = assetDirectory + "idle.dae"
        let idleAnimation = self.loadAndCacheAnimation(fileName, withSkeletonNode:skeletonName, forKey:EnemyCharacter.keyForAnimationType(EnemyAnimationState.Idle))
        idleAnimation.repeatCount = FLT_MAX;
        idleAnimation.fadeInDuration = 0.15
        idleAnimation.fadeOutDuration = 0.15
        
    }
    
    func setupWalkAnimation()
    {
        let fileName = assetDirectory + "walk.dae"
        let walkAnimation = self.loadAndCacheAnimation(fileName, withSkeletonNode:skeletonName, forKey:EnemyCharacter.keyForAnimationType(EnemyAnimationState.Walk))
        walkAnimation.repeatCount = FLT_MAX;
        walkAnimation.fadeInDuration = 0.15
        walkAnimation.fadeOutDuration = 0.15
    }
    
    func setupDieAnimation()
    {
        let fileName = assetDirectory + "die.dae"
        let dieAnimation = self.loadAndCacheAnimation(fileName, withSkeletonNode:skeletonName, forKey:EnemyCharacter.keyForAnimationType(EnemyAnimationState.Die))
        dieAnimation.repeatCount = 1;
        dieAnimation.removedOnCompletion = false
        dieAnimation.fadeInDuration = 0.15
        dieAnimation.fadeOutDuration = 0.25
        
    }

    func setupRunAnimation()
    {
        let fileName = assetDirectory + "run.dae"
        let runAnimation = self.loadAndCacheAnimation(fileName, withSkeletonNode:skeletonName, forKey:EnemyCharacter.keyForAnimationType(EnemyAnimationState.Run))
        runAnimation.repeatCount = FLT_MAX;
        runAnimation.fadeInDuration = 0.15
        runAnimation.fadeOutDuration = 0.15
    }
    
    func setupAttackAnimation()
    {
        let fileName = assetDirectory + "attack.dae"
        let attackAnimation = self.loadAndCacheAnimation(fileName, withSkeletonNode:skeletonName, forKey:EnemyCharacter.keyForAnimationType(EnemyAnimationState.Attack))
        attackAnimation.repeatCount = FLT_MAX;
        attackAnimation.fadeInDuration = 0.15
        attackAnimation.fadeOutDuration = 0.15
    }

    func changeAnimationState(newState:EnemyAnimationState)
    {
        let newKey = EnemyCharacter.keyForAnimationType(newState)
        let currentKey = EnemyCharacter.keyForAnimationType(previousState)
        
        let runAnim = self.cachedAnimationForKey(newKey)
        runAnim.fadeInDuration = 0.15
        self.mainSkeleton.removeAnimationForKey(currentKey, fadeOutDuration:0.15)
        self.mainSkeleton.addAnimation(runAnim, forKey:newKey)
        
    }

    func canSeePlayer() -> Bool {
        return true
    }
    
    func chasePlayer() {
        //steering.seekOn = true
        //steering.pursueTarget(self.player)
        //steering.evadeTarget(self.player)
        //steering.wanderOn = true
        
        /*
        let gLevel = gameLevel as? GameLevel0
        let gameObjects = gLevel?.gameObjects
        steering.avoidCollisionsOn(gameObjects!)
        
        //steering.hideOn(self.player, gameObjects: gameObjects!)
        
        steering.followPathOn(self.patrolPath)
        */
    }
    
    func changeState(newState:State) {
        stateMachine.changeState(newState)
    }

    func updatePosition(deltaTime:NSTimeInterval) {
        
        //calculate the combined force from each steering behavior
        //let steeringForce = steering.seek(SCNVector3Make(0.0, 0.0, 100))
        //let steeringForce = steering.flee(SCNVector3Make(20.0, 0.0, -44.0))
        //let steeringForce = steering.arrive(SCNVector3Make(0.0, 0.0, 100), deceleration: Deceleration.slow)
        let steeringForce = steering.calculate()

        //acceleration = Force/mass
        let acceleration = Vector3D(x:steeringForce.x/self.getMass(), y:0.0, z:steeringForce.z/self.getMass())
        
        //update velocity
        velocity.x = velocity.x + acceleration.x*Float(deltaTime)
        velocity.z = velocity.z + acceleration.z*Float(deltaTime)
        
        //make sure velocity does not exceed maximum velocity
        velocity = velocity.truncate(self.getMaxSpeed())
        
        //update the heading if the vehicle has a non zero velocity
        if (velocity.lengthSquared() > 0.00000001)
        {
            heading = velocity.normalized()
            
            side = heading.perp()
        }

        //update the position
        var newPlayerPos = SCNVector3Zero
        newPlayerPos.x = self.position.x + GFloat(velocity.x)*GFloat(deltaTime)
        newPlayerPos.z = self.position.z + GFloat(velocity.z)*GFloat(deltaTime)
        newPlayerPos.y = self.position.y
        
        let angleDirection = GameUtilities.getAngleFromDirection(self.position, target:newPlayerPos)
        
        self.rotation = SCNVector4Make(0, 1, 0, GFloat(angleDirection))

        //update the position
        self.position = newPlayerPos

    }

    func update(deltaTime:NSTimeInterval) {
        if(self.status == EnemyStatus.Alive) {
            //stateMachine.update()
        
            //process the currently active goal.
            brain.process()
        
            self.updatePosition(deltaTime)

            //appraise and arbitrate between all possible high level goals
        
            if (goalArbitrationRegulator.isReady()) {
                brain.arbitrate()
            }
        }
        
    }
    
    func isStatic() -> Bool {
        return false
    }
    
    func getID() -> String {
        return self.name!
    }

    func getPosition() -> SCNVector3 {
        return self.position
    }
    
    func getVelocity() -> Vector3D {
        return self.velocity

    }
    // A normalized vector describing the direction of the object
    func getHeading() -> Vector3D {
        return self.heading

    }
    // A vector perpendicular to the heading
    func getPerp() -> Vector3D {
        return self.side

    }
    
    func getMass() -> Float {
        return self.mass
    }
    func getMaxSpeed() -> Float {
        return self.maxSpeed
    }
    func getMaxForce() -> Float {
        return self.maxForce
    }
    //turn rate in radians per sec
    func getMaxTurnRate() -> Float {
        return self.maxTurnRate
    }
    
    func getObjectScale() -> GFloat {
        return 0.20
    }

    func getObjectPosition() -> SCNVector3 {
        return self.position
    }

    func getBoundingRadius() -> Float {
        return boundingRadius
    }
    
    func getSteering() -> SteeringBehavior {
        return self.steering
    }

    func getHealth() -> Float {
        return self.health
    }
}