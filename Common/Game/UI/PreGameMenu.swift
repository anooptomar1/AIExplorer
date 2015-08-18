//
//  PreGameMenu.swift
//  SwiftExplorer
//
//  Created by Vivek Nagar on 8/13/14.
//  Copyright (c) 2014 Vivek Nagar. All rights reserved.
//

import SpriteKit

class PreGameMenu :SKNode {
    var size:CGSize!
    var myLabel:SKLabelNode!
    let levelName1 = "Level 1"
    let levelName2 = "Level 2"
    let levelName3 = "Level 3"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    init(size:CGSize) {
        super.init()
        
        self.name = "PreGameMenu"
        self.size = size;
        self.userInteractionEnabled = true
        myLabel = GameUIManager.labelWithText(levelName1, textSize: 30)
        myLabel.position = CGPointMake(size.width/2, size.height/2 + 20)
        self.addChild(myLabel)
        
        myLabel = GameUIManager.labelWithText(levelName2, textSize: 30)
        myLabel.position = CGPointMake(size.width/2, size.height/2 - 20)
        self.addChild(myLabel)

        myLabel = GameUIManager.labelWithText(levelName3, textSize: 30)
        myLabel.position = CGPointMake(size.width/2, size.height/2 - 40)
        self.addChild(myLabel)

    }
    
    #if os(iOS)
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches as Set<UITouch>, withEvent:event)
        
        let touch:UITouch = touches.first as UITouch!

        let location:CGPoint = touch.locationInNode(scene!)
        let node:SKNode = scene!.nodeAtPoint(location)
        print("NODE NAME IS \(node.name)")
        var levelIndex = 0
        if(node.name == levelName1) {
            levelIndex = 0
        } else if(node.name == levelName2) {
            levelIndex = 1
        } else if(node.name == levelName3) {
            levelIndex = 2
        } else {
            return
        }
        self.hidden = true
        GameScenesManager.sharedInstance.setGameState(GameState.InGame, levelIndex: levelIndex)
    }
    #else
    override func mouseUp(event:NSEvent)
    {
        super.mouseUp(event)
        let location:CGPoint = event.locationInNode(self)
        let node:SKNode = scene!.nodeAtPoint(location)
        print("NODE NAME IS \(node.name)")
        var levelIndex = 0
        if(node.name == levelName1) {
            levelIndex = 0
        } else if(node.name == levelName2) {
            levelIndex = 1
        } else if(node.name == levelName3) {
            levelIndex = 2
        } else {
            return
        }

        self.hidden = true
        GameScenesManager.sharedInstance.setGameState(GameState.InGame, levelIndex:levelIndex)
    }
    #endif
}
