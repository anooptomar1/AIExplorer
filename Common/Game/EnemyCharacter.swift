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

class EnemyCharacter : SkinnedCharacter {
    var stateMachine: StateMachine!
    let assetDirectory = "art.scnassets/common/models/warrior/"
    let skeletonName = "Bip01"
    let helpNotificationKey = "HelpKey"
    
    var currentState:EnemyAnimationState = EnemyAnimationState.Idle
    var previousState:EnemyAnimationState = EnemyAnimationState.Idle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
        
    init(characterNode:SCNNode, id:String) {
        super.init(rootNode: characterNode)
        self.name = id
        
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
            selector: "helpNotification:",
            name: helpNotificationKey,
            object: nil)
    }
    
    func helpNotification(notification:NSNotification) {
        let obj = notification.object as! Message
        if(self.name != obj.sender) {
            print("\(self.name) received help notification from \(obj.sender)")
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

    override func update(deltaTime:NSTimeInterval) {
        stateMachine.update()
    }
    
    override func isStatic() -> Bool {
        return false
    }
    
    override func getID() -> String {
        return self.name!
    }

}