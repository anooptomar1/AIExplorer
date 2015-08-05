//
//  GameUIManager.swift
//  SwiftExplorer
//
//  Created by Vivek Nagar on 8/13/14.
//  Copyright (c) 2014 Vivek Nagar. All rights reserved.
//

import SpriteKit

class GameUIManager {
    var delegate:GameLevel!
    var skScene: SKScene!
    var preGameMenu : PreGameMenu!
    var inGameMenu : InGameMenu!
    var levelCompleteMenu: LevelCompleteMenu!
    var levelFailedMenu : LevelFailedMenu!
    
    // Singleton
    class var sharedInstance : GameUIManager {
    struct Static {
        static let instance : GameUIManager = GameUIManager()
        }
        return Static.instance
    }
    
    init() {
    }

    func setScene(scene: SKScene) {
        skScene = scene;
        self.changeUIState(GameState.PreGame)

    }
    
    
    func changeUIState(state: GameState) {
        preGameMenu?.removeFromParent()
        inGameMenu?.removeFromParent()
        levelCompleteMenu?.removeFromParent()
        levelFailedMenu?.removeFromParent()
        
        switch(state) {
            case GameState.PreGame:
                preGameMenu = PreGameMenu(size: skScene.frame.size)
                skScene.addChild(preGameMenu)
                break;
            case GameState.InGame:
                inGameMenu = InGameMenu(size:skScene.frame.size, level:delegate)
                skScene.addChild(inGameMenu)
                break;
            case GameState.LevelFailed:
                levelFailedMenu = LevelFailedMenu(size: skScene.frame.size)
                skScene.addChild(levelFailedMenu)
                break;
            case GameState.LevelComplete:
                levelCompleteMenu = LevelCompleteMenu(size: skScene.frame.size)
                skScene.addChild(levelCompleteMenu)
                break;
            case GameState.PostGame:
                break;
            default:
                break;
        }
    }
    
    class func labelWithText(text:String, textSize:CGFloat)->SKLabelNode {
        let fontName:String = "Optima-ExtraBlack"
        let myLabel:SKLabelNode = SKLabelNode(fontNamed: fontName)
        
        myLabel.text = text
        myLabel.fontSize = textSize;
        myLabel.fontColor = SKColor.yellowColor();
        
        return myLabel;

    }
    
    class func dropShadowOnLabel(frontLabel:SKLabelNode) -> SKLabelNode {
        let myLabelBackground:SKLabelNode = frontLabel.copy() as! SKLabelNode
        myLabelBackground.userInteractionEnabled = false
        myLabelBackground.fontColor = SKColor.blackColor();
        myLabelBackground.position = CGPointMake(2 + frontLabel.position.x, -2 + frontLabel.position.y);
        
        myLabelBackground.zPosition = frontLabel.zPosition - 1;
        frontLabel.parent!.addChild(myLabelBackground);
        return myLabelBackground;
    }
}