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
    var currentLevel: GameLevel!
    
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
        let currentLevelIndex = 0
        let gameLevel:GameLevel = createGameLevel(levelName + String(currentLevelIndex))
        currentLevel = gameLevel

        setupGameLevel(gameLevel)
    }
    
    func createGameLevel(levelName:String) -> GameLevel {
        //print("My class is \(self.dynamicType)", appendNewline: false)
        //var level : GameLevel! = nil
        
        let lName = namespace + "." + levelName
        
        let aClass = NSClassFromString(lName) as! NSObject.Type
        let level:GameLevel = aClass.init() as! GameLevel
        
        return level
    }
    
    func setupGameLevel(level:GameLevel) {
        // Setup the game overlays using SpriteKit.
        let overlayScene:GameOverlayScene = GameOverlayScene(size: scnView.bounds.size)
        scnView.overlaySKScene = overlayScene;
        let scene:SCNScene = level.createLevel(scnView)
        
        scnView.backgroundColor = SKColor.blackColor()
        scnView.scene = scene
        scnView.delegate = level
        // Workaround to refresh
        scnView.playing = true
        
        //scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        
        scnView.scene!.physicsWorld.contactDelegate = level
        //scnView.scene!.physicsWorld.gravity = SCNVector3Make(0, -800, 0)
        //scnView.scene!.physicsWorld.speed = 4.0
        
        // Hide scene till game starts playing
        scnView.scene!.rootNode.hidden = true

        self.setGameState(GameState.PreGame)
    }
    
    func setGameState(gameState:GameState) {
        
        self.gameState = gameState;
        currentLevel.changeUIState(gameState)
        
        switch(gameState) {
        case .PreGame:
            scnView.scene!.rootNode.hidden = true
            break;
        case .InGame:
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
            break;
        case .Paused:
            scnView.scene!.rootNode.hidden = false
            currentLevel.pauseLevel()
            scnView.pause(self)
            break;
        }
    }
    
}
