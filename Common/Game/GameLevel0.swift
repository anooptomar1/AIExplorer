//
//  GameLevel0.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/5/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

class GameLevel0 : NSObject, GameLevel {

    var scene : SCNScene!
    var scnView : SCNView!
    var previousTime:NSTimeInterval!
    var deltaTime:NSTimeInterval!
    
    override init() {
        super.init()
        
        previousTime = 0.0
        deltaTime = 0.0
    }
    
    
    func createLevel(scnView:SCNView) -> SCNScene {
        self.scnView = scnView
        // create a new scene
        self.scene = SCNScene(named: "art.scnassets/level0/ship.dae")!
        
        // create and add a camera to the scene
        let cameraNode = GameCamera(cameraType:CameraType.SceneCamera)
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.setupTransformationMatrix()
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = SKColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
        let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
        
        // animate the 3d object
        ship.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 1)))
        
        let gameUIManager:GameUIManager = GameUIManager.sharedInstance
        gameUIManager.setScene(scnView.overlaySKScene!)
        // set delegate to get menu action callbacks
        gameUIManager.delegate = self


        return self.scene
    }
    
    func renderer(aRenderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        //TEMPORARY - REMOVE THIS WHEN GAME MENUS ARE IMPLEMENTED
        //GameScenesManager.sharedInstance.setGameState(GameState.InGame)

        if(previousTime == 0.0) {
            previousTime = time
        }
        deltaTime = time - previousTime
        previousTime = time
        
    }

    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        print("Contact between nodes: \(contact.nodeA.name) and \(contact.nodeB.name)")
    }

}

//MARK: GameLevel protocol methods
extension GameLevel0 {
    func startLevel() {
    }
    
    func pauseLevel() {
        self.scene.paused = true
    }
    
    func stopLevel() {
        // reset level
    }
    
    func changeUIState(state:GameState) {
        let skScene = self.scnView.overlaySKScene
        
        GameUIManager.sharedInstance.preGameMenu?.removeFromParent()
        GameUIManager.sharedInstance.inGameMenu?.removeFromParent()
        GameUIManager.sharedInstance.levelCompleteMenu?.removeFromParent()
        GameUIManager.sharedInstance.levelFailedMenu?.removeFromParent()
        
        switch(state) {
        case GameState.PreGame:
            GameUIManager.sharedInstance.preGameMenu = PreGameMenu(size: skScene!.frame.size)
            skScene!.addChild(GameUIManager.sharedInstance.preGameMenu)
            break;
        case GameState.InGame:
            GameUIManager.sharedInstance.inGameMenu = InGameMenu(size:skScene!.frame.size, level:self)
            skScene!.addChild(GameUIManager.sharedInstance.inGameMenu)
            break;
        case GameState.LevelFailed:
            GameUIManager.sharedInstance.levelFailedMenu = LevelFailedMenu(size: skScene!.frame.size)
            skScene!.addChild(GameUIManager.sharedInstance.levelFailedMenu)
            break;
        case GameState.LevelComplete:
            GameUIManager.sharedInstance.levelCompleteMenu = LevelCompleteMenu(size: skScene!.frame.size)
            skScene!.addChild(GameUIManager.sharedInstance.levelCompleteMenu)
            break;
        case GameState.PostGame:
            break;
        default:
            break;
        }

    }
    
    func buttonPressedAction(nodeName:String) {
        print("Button pressed \(nodeName)")

    }
}
