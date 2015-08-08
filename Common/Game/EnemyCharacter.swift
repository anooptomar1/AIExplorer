//
//  EnemyCharacter.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/6/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import SceneKit

enum EnemyAnimationState : Int {
    case Die = 0,
    Run,
    Idle,
    Walk,
    Attack
}

class EnemyCharacter : SkinnedCharacter, MovingGameObject {
    let mass:Float = 4.0
    let maxSpeed:Float = 20.0
    let maxForce:Float = 5.0
    let maxTurnRate:Float = 0.0
    var velocity = Vector2D(x:0.0, z:0.0)
    
    var gameLevel:GameLevel!
    var stateMachine: StateMachine!
    var steering:SteeringBehavior!
    
    let assetDirectory = "art.scnassets/common/models/warrior/"
    let skeletonName = "Bip01"
    let notificationKey = "NotificationKey"
    
    var currentState:EnemyAnimationState = EnemyAnimationState.Idle
    var previousState:EnemyAnimationState = EnemyAnimationState.Idle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
        
    init(characterNode:SCNNode, id:String, level:GameLevel) {
        super.init(rootNode: characterNode)
        self.name = id
        self.gameLevel = level
        self.steering = SteeringBehavior(obj:self)
        
        // Load the animations and store via a lookup table.
        self.setupIdleAnimation()
        self.setupRunAnimation()
        self.setupWalkAnimation()
        self.setupDieAnimation()
        self.setupAttackAnimation()
        
        stateMachine = StateMachine(owner: self)
        stateMachine.setCurrentState(EnemyIdleState.sharedInstance)
        stateMachine.changeState(EnemyIdleState.sharedInstance)

        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "handleNotification:",
            name: notificationKey,
            object: nil)
    }
    
    func handleNotification(notification:NSNotification) {
        let obj = notification.object as! Message
        if(self.name != obj.sender) {
            stateMachine.handleMessage(obj)
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
        dieAnimation.repeatCount = FLT_MAX;
        dieAnimation.fadeInDuration = 0.15
        dieAnimation.fadeOutDuration = 0.15
        
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

    func changeState(newState:State) {
        stateMachine.changeState(newState)
    }

    func updatePosition(deltaTime:NSTimeInterval) {
        
        //calculate the combined force from each steering behavior
        //let steeringForce = steering.seek(SCNVector3Make(0.0, 0.0, 100))
        let steeringForce = steering.flee(SCNVector3Make(20.0, 0.0, -44.0))

        
        //acceleration = Force/mass
        let acceleration = Vector2D(x:steeringForce.x/self.getMass(), z:steeringForce.z/self.getMass())
        
        //update velocity
        velocity.x = velocity.x + acceleration.x*Float(deltaTime)
        velocity.z = velocity.z + acceleration.z*Float(deltaTime)
        
        //make sure velocity does not exceed maximum velocity
        velocity = velocity.truncate(self.getMaxSpeed())
        
        //update the position
        var newPlayerPos = SCNVector3Zero
        #if os(iOS)
            newPlayerPos.x = self.position.x + velocity.x*Float(deltaTime)
            newPlayerPos.z = self.position.z + velocity.z*Float(deltaTime)
        #else
            newPlayerPos.x = self.position.x + CGFloat(velocity.x)*CGFloat(deltaTime)
            newPlayerPos.z = self.position.z + CGFloat(velocity.z)*CGFloat(deltaTime)
        #endif
        newPlayerPos.y = self.position.y
        
        let angleDirection = GameUtilities.getAngleFromDirection(self.position, target:newPlayerPos)
        
        #if os(iOS)
            self.rotation = SCNVector4Make(0, 1, 0, angleDirection)
            #else
            self.rotation = SCNVector4Make(0, 1, 0, CGFloat(angleDirection))
        #endif

        //update the position
        self.position = newPlayerPos

    }

    override func update(deltaTime:NSTimeInterval) {
        stateMachine.update()
        self.updatePosition(deltaTime)
    }
    
    override func isStatic() -> Bool {
        return false
    }
    
    override func getID() -> String {
        return self.name!
    }

    func getPosition() -> SCNVector3 {
        return self.position
    }
    
    func getVelocity() -> Vector2D {
        return Vector2D(x: 1.0, z: 1.0)

    }
    // A normalized vector describing the direction of the object
    func getHeading() -> Vector2D {
        return Vector2D(x: 0, z: 0)

    }
    // A vector perpendicular to the heading
    func getPerp() -> Vector2D {
        return Vector2D(x: 0, z: 0)

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

}