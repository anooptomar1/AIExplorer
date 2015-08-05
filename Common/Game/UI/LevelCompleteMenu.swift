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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    init(size:CGSize) {
        super.init()
        
        self.size = size;
        self.userInteractionEnabled = true
        
        myLabel = GameUIManager.labelWithText("Level Complete", textSize: 40)
        myLabel.position = CGPointMake(size.width/2, size.height/2)
        self.addChild(myLabel)
    }

    #if os(iOS)
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent:event)
        self.hidden = true
        GameScenesManager.sharedInstance.setGameState(GameState.PreGame)
    }
    #else
    override func mouseUp(event:NSEvent)
    {
        super.mouseUp(event)
        self.hidden = true
        GameScenesManager.sharedInstance.setGameState(GameState.PreGame)
    }

    #endif

}