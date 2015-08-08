//
//  PlayerCharacter.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/6/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import SceneKit


enum PlayerAnimationState : Int {
    case Die = 0,
    Run,
    Jump,
    JumpFalling,
    JumpLand,
    Idle,
    GetHit,
    Bored,
    RunStart,
    RunStop,
    Walk,
    Unknown
}

class PlayerCharacter : SkinnedCharacter, MovingGameObject {
    var gameLevel:GameLevel!
    let speed:Float = 0.1
    var stateMachine: StateMachine!
    let assetDirectory = "art.scnassets/common/models/explorer/"
    let skeletonName = "Bip001_Pelvis"
    var currentState : PlayerAnimationState = PlayerAnimationState.Idle
    var previousState : PlayerAnimationState = PlayerAnimationState.Idle

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(characterNode:SCNNode, id:String, level:GameLevel) {
        super.init(rootNode: characterNode)
        
        self.name = id
        self.gameLevel = level
        
        // Load the animations and store via a lookup table.
        self.setupIdleAnimation()
        self.setupWalkAnimation()
        self.setupBoredAnimation()
        self.setupHitAnimation()

        stateMachine = StateMachine(owner: self)
        stateMachine.setCurrentState(PlayerIdleState.sharedInstance)
        stateMachine.changeState(PlayerIdleState.sharedInstance)

        //self.changeAnimationState(.Idle)
    }
    
    class func keyForAnimationType(animType:PlayerAnimationState) -> String!
    {
        switch (animType) {
        case .Bored:
            return "bored-1"
        case .Die:
            return "die-1"
        case .GetHit:
            return "hit-1"
        case .Idle:
            return "idle-1"
        case .Jump:
            return "jump_start-1"
        case .JumpFalling:
            return "jump_falling-1"
        case .JumpLand:
            return "jump_land-1"
        case .Run:
            return "run-1"
        case .RunStart:
            return "run_start-1"
        case .RunStop:
            return "run_stop-1"
        case .Walk:
            return "walk-1"
        default:
            return "unknown"
        }
    }

    func changeAnimationState(newState:PlayerAnimationState)
    {
        let newKey = PlayerCharacter.keyForAnimationType(newState)
        let currentKey = PlayerCharacter.keyForAnimationType(previousState)
        
        let runAnim = self.cachedAnimationForKey(newKey)
        runAnim.fadeInDuration = 0.15;
        self.mainSkeleton.removeAnimationForKey(currentKey, fadeOutDuration:0.15)
        self.mainSkeleton.addAnimation(runAnim, forKey:newKey)
    }

    func setupIdleAnimation()
    {
        let fileName = assetDirectory + "idle.dae"
        let idleAnimation = self.loadAndCacheAnimation(fileName, withSkeletonNode:skeletonName, forKey:PlayerCharacter.keyForAnimationType(.Idle))
        idleAnimation.repeatCount = FLT_MAX;
        idleAnimation.fadeInDuration = 0.15;
        idleAnimation.fadeOutDuration = 0.15;
    }
    
    func setupWalkAnimation()
    {
        let fileName = assetDirectory + "walk.dae"
        
        let walkAnimation = self.loadAndCacheAnimation(fileName, withSkeletonNode:skeletonName, forKey:PlayerCharacter.keyForAnimationType(.Walk))
        walkAnimation.repeatCount = FLT_MAX;
        walkAnimation.fadeInDuration = 0.15;
        walkAnimation.fadeOutDuration = 0.15;
    }
    
    func setupBoredAnimation()
    {
        let fileName = assetDirectory + "bored.dae"
        
        let boredAnimation = self.loadAndCacheAnimation(fileName, withSkeletonNode:skeletonName, forKey:PlayerCharacter.keyForAnimationType(.Bored))
        boredAnimation.repeatCount = FLT_MAX;
        boredAnimation.fadeInDuration = 0.15;
        boredAnimation.fadeOutDuration = 0.15;
    }
    
    func setupHitAnimation()
    {
        let fileName = assetDirectory + "hit.dae"
        
        let animation = self.loadAndCacheAnimation(fileName, withSkeletonNode:skeletonName, forKey:PlayerCharacter.keyForAnimationType(.GetHit))
        animation.fadeInDuration = 0.15;
        animation.fadeOutDuration = 0.15;
        animation.repeatCount = FLT_MAX;
    }

    func changeState(newState:State) {
        stateMachine.changeState(newState)
    }
    
    func updatePosition(velocity:CGPoint) {
        let delX = velocity.x * CGFloat(speed)
        let delZ = velocity.y * CGFloat(speed)
        
        #if os(iOS)
            var newPlayerPos = SCNVector3Make(self.position.x+Float(delX), self.position.y, self.position.z+Float(delZ))
        #else
            var newPlayerPos = SCNVector3Make(self.position.x+CGFloat(delX), self.position.y, self.position.z+CGFloat(delZ))
        #endif
        let angleDirection = GameUtilities.getAngleFromDirection(self.position, target:newPlayerPos)
        
        let height:Float = 0.0
        //height = self.getGroundHeight(newPlayerPos)
        //print("ground height is \(height)")
        
        #if os(iOS)
            newPlayerPos = SCNVector3Make(self.position.x+Float(delX), height, self.position.z+Float(delZ))
            self.rotation = SCNVector4Make(0, 1, 0, angleDirection)
        #else
            newPlayerPos = SCNVector3Make(self.position.x+CGFloat(delX), CGFloat(height), self.position.z+CGFloat(delZ))
            self.rotation = SCNVector4Make(0, 1, 0, CGFloat(angleDirection))
        #endif
        self.position = newPlayerPos

    }
    
    override func update(deltaTime:NSTimeInterval) {
        //update state machine
        stateMachine.update()
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
        return Vector2D(x: 0, z: 0)
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
        return 0.0
    }
    func getMaxSpeed() -> Float {
        return 0.0
    }
    func getMaxForce() -> Float {
        return 0.0
    }
    //turn rate in radians per sec
    func getMaxTurnRate() -> Float {
        return 0.0
    }

}
