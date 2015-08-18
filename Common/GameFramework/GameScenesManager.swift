//
//  GameScenesManager.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/4/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

#if os(iOS)
    typealias GFloat = Float
#else
    typealias GFloat = CGFloat
#endif

@objc enum GameState :Int {
    case PreGame=0, InGame, Paused, LevelComplete, LevelFailed, PostGame
}


class GameScenesManager {
    let levelName = "GameLevel"
    #if os(iOS)
    let namespace = "AIExplorer"
    #else
    let namespace = "MacOSXAIExplorer"
    #endif
    
    var gameState: GameState
    var scnView : SCNView!
    
    var gameLevels:[GameLevel] = [GameLevel]()
    var currentLevel: GameLevel!
    var currentLevelIndex:Int = 0
    
    // Singleton
    class var sharedInstance : GameScenesManager {
        struct Static {
            static let instance : GameScenesManager = GameScenesManager()
        }
        return Static.instance
    }
    
    init() {
        gameState = GameState.PreGame
    }
    
    func setView(view:SCNView) {
        scnView = view
    }
    
    //Setup all the game levels and initialize to first level
    func setupLevels() {
        // Setup the game overlays using SpriteKit.
        let overlayScene:GameOverlayScene = GameOverlayScene(size: scnView.bounds.size)
        scnView.overlaySKScene = overlayScene;
        scnView.backgroundColor = SKColor.grayColor()
        //scnView.allowsCameraControl = true
        scnView.showsStatistics = true

        for levelIndex in 0...2 {
            let level:GameLevel = createGameLevel(levelName + String(levelIndex))
            gameLevels.append(level)
        }
        
        //self.setGameState(GameState.PreGame)
        GameUIManager.sharedInstance.setScene(overlayScene)
        GameUIManager.sharedInstance.changeUIState(GameState.PreGame)
        gameState = GameState.PreGame
        scnView.scene = SCNScene()
        scnView.playing = true

    }
    
    func createGameLevel(levelName:String) -> GameLevel {
        //print("My class is \(self.dynamicType)", appendNewline: false)
        //var level : GameLevel! = nil
        
        let lName = namespace + "." + levelName
        
        let aClass = NSClassFromString(lName) as! NSObject.Type
        let level:GameLevel = aClass.init() as! GameLevel
        
        return level
    }
    
    func setupGameLevel(level:GameLevel) -> SCNScene {
        let scene:SCNScene = level.createLevel(scnView)
        scnView.scene = scene
        scnView.delegate = level
        scnView.scene!.physicsWorld.contactDelegate = level
        //scnView.scene!.physicsWorld.gravity = SCNVector3Make(0, -800, 0)
        //scnView.scene!.physicsWorld.speed = 4.0
        
        // Hide scene till game starts playing
        scnView.scene!.rootNode.hidden = true
        // Workaround to refresh
        scnView.playing = true
        
        return scene
    }
    
    func setGameState(gameState:GameState, levelIndex:Int) {
        
        switch(gameState) {
        case .PreGame:
            //scnView.scene!.rootNode.hidden = true
            break;
        case .InGame:
            currentLevelIndex = levelIndex
            if(currentLevelIndex < gameLevels.count) {
                currentLevel = gameLevels[currentLevelIndex]
                let newScene = setupGameLevel(currentLevel)
                self.transitionScene(newScene)
                currentLevel = gameLevels[levelIndex]
                let _ = setupGameLevel(gameLevels[levelIndex])
            }
 
            scnView.scene!.rootNode.hidden = false
            currentLevel.startLevel()
            scnView.play(self)
            break;
        case .PostGame:
            scnView.scene!.rootNode.hidden = true
            currentLevel.stopLevel()
            scnView.stop(self)
            break;
        case .LevelComplete:
            scnView.scene!.rootNode.hidden = true
            currentLevel.stopLevel()
            scnView.stop(self)
            break;
        case .LevelFailed:
            scnView.scene!.rootNode.hidden = true
            currentLevel.stopLevel()
            scnView.stop(self)
            //self.transitionScene(newScene)
            break;
        case .Paused:
            scnView.scene!.rootNode.hidden = false
            currentLevel.pauseLevel()
            scnView.pause(self)
            break;
        }
        
        currentLevel.changeUIState(gameState)
        self.gameState = gameState;

    }
    
    func transitionScene(scene:SCNScene) {
        /*
        let sceneTransition = SKTransition.doorsCloseHorizontalWithDuration(2.0)
        scnView.presentScene(scene, withTransition: sceneTransition, incomingPointOfView:nil, completionHandler:nil)
        */
    }
    
}
