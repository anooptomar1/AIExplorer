//
//  LevelCompleteMenu.swift
//  SwiftExplorer
//
//  Created by Vivek Nagar on 8/13/14.
//  Copyright (c) 2014 Vivek Nagar. All rights reserved.
//

import SpriteKit

class LevelCompleteMenu : SKNode {
    var size:CGSize!
    var myLabel:SKLabelNode!
    var nextLevelLabelName = "Next Level"
    var mainMenuLabelName = "Main Menu"

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    init(size:CGSize) {
        super.init()
        
        self.size = size;
        self.userInteractionEnabled = true
        
        myLabel = GameUIManager.labelWithText("Level Complete", textSize: 40)
        myLabel.position = CGPointMake(size.width/2, size.height/2 + 20)
        self.addChild(myLabel)
        myLabel = GameUIManager.labelWithText(nextLevelLabelName, textSize: 30)
        myLabel.position = CGPointMake(size.width/2, size.height/2 - 20)
        self.addChild(myLabel)
        
        myLabel = GameUIManager.labelWithText(mainMenuLabelName, textSize: 30)
        myLabel.position = CGPointMake(size.width/2, size.height/2 - 40)
        self.addChild(myLabel)
    }

    #if os(iOS)
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent:event)
        let touch:UITouch = touches.first as UITouch!
    
        let location:CGPoint = touch.locationInNode(scene!)
        let node:SKNode = scene!.nodeAtPoint(location)
    
        print("NODE NAME IS \(node.name)")
        let levelIndex = GameScenesManager.sharedInstance.currentLevelIndex
    
        if(node.name == nextLevelLabelName) {
            GameScenesManager.sharedInstance.setGameState(GameState.InGame, levelIndex:levelIndex+1)
        } else if(node.name == mainMenuLabelName) {
            GameScenesManager.sharedInstance.setGameState(GameState.PreGame, levelIndex:levelIndex)
        } else {
            return
        }
        self.hidden = true
    }
    #else
    override func mouseUp(event:NSEvent)
    {
        super.mouseUp(event)
        let location:CGPoint = event.locationInNode(self)
        let node:SKNode = scene!.nodeAtPoint(location)
        print("NODE NAME IS \(node.name)")
        let levelIndex = GameScenesManager.sharedInstance.currentLevelIndex
        
        if(node.name == nextLevelLabelName) {
            GameScenesManager.sharedInstance.setGameState(GameState.InGame, levelIndex:levelIndex+1)
        } else if(node.name == mainMenuLabelName) {
            GameScenesManager.sharedInstance.setGameState(GameState.PreGame, levelIndex:levelIndex)
        } else {
            return
        }

        self.hidden = true
    }

    #endif

}