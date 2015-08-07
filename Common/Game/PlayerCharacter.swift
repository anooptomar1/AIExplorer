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

class PlayerCharacter : SkinnedCharacter {
    var stateMachine: StateMachine!
    let assetDirectory = "art.scnassets/common/models/explorer/"
    let skeletonName = "Bip001_Pelvis"
    var currentState : PlayerAnimationState = PlayerAnimationState.Idle
    var previousState : PlayerAnimationState = PlayerAnimationState.Idle

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(characterNode:SCNNode, id:String) {
        super.init(rootNode: characterNode)
        
        self.name = id
        
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
}
