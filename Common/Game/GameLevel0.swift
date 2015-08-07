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
    
    var sceneCamera:GameCamera!
    var frontCamera:GameCamera!
    var currentCamera:GameCamera!
    var player:PlayerCharacter!
    var enemies:[EnemyCharacter] = [EnemyCharacter]()
    var ship:SCNNode!
    
    override init() {
        super.init()
        
        previousTime = 0.0
        deltaTime = 0.0
    }
    
    
    func createLevel(scnView:SCNView) -> SCNScene {
        self.scnView = scnView
        // create a new scene
        self.scene = SCNScene(named: "art.scnassets/level0/ship.dae")!
        
        let gameUIManager:GameUIManager = GameUIManager.sharedInstance
        gameUIManager.setScene(scnView.overlaySKScene!)
        // set delegate to get menu action callbacks
        gameUIManager.delegate = self

        
        // create and add a camera to the scene
        sceneCamera = GameCamera(cameraType:CameraType.SceneCamera)
        sceneCamera.camera?.zFar = 400.0
        // place the camera
        sceneCamera.position = SCNVector3(x: 0, y: 110, z: 200)
        #if os(iOS)
            sceneCamera.rotation = SCNVector4Make(1.0, 0.0, 0.0, -Float(M_PI_4*0.75))
        #else
            sceneCamera.rotation = SCNVector4Make(1.0, 0.0, 0.0, -CGFloat(M_PI_4*0.75))
        #endif

        scene.rootNode.addChildNode(sceneCamera)
        sceneCamera.setupTransformationMatrix()
        currentCamera = sceneCamera
        
        
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
        
        self.addFloorAndWalls()
        self.addPlayer()
        self.addEnemies()
        
        // retrieve the ship node
        ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
        
        ship.position = SCNVector3(x:0.0, y:30.0, z:0.0)
        // animate the 3d object
        ship.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 1)))
        


        return self.scene
    }
    
    func addFloorAndWalls() {
        //add floor
        let floorNode = SCNNode()
        let floor = SCNFloor()
        floor.reflectionFalloffEnd = 2.0
        floorNode.geometry = floor
        floorNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/level0/wood.png"
        floorNode.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(2, 2, 1); //scale the wood texture
        floorNode.geometry?.firstMaterial?.locksAmbientWithDiffuse = true
        floorNode.physicsBody = SCNPhysicsBody.staticBody()
        scene.rootNode.addChildNode(floorNode)
        
        //add walls
        var wall = SCNNode(geometry:SCNBox(width:400, height:100, length:4, chamferRadius:0))
        wall.geometry!.firstMaterial!.diffuse.contents = "art.scnassets/level0/wall.jpg"
        wall.geometry!.firstMaterial!.diffuse.contentsTransform = SCNMatrix4Mult(SCNMatrix4MakeScale(24, 2, 1), SCNMatrix4MakeTranslation(0, 1, 0));
        wall.geometry!.firstMaterial!.diffuse.wrapS = SCNWrapMode.Repeat;
        wall.geometry!.firstMaterial!.diffuse.wrapT = SCNWrapMode.Mirror;
        wall.geometry!.firstMaterial!.doubleSided = false;
        wall.castsShadow = false;
        wall.geometry!.firstMaterial!.locksAmbientWithDiffuse = true;
        
        wall.position = SCNVector3Make(0, 50, -198);
        wall.physicsBody = SCNPhysicsBody.staticBody()
        scene.rootNode.addChildNode(wall)
        
        wall = wall.clone()
        wall.position = SCNVector3Make(-202, 50, 0);
        #if os(iOS)
            wall.rotation = SCNVector4Make(0.0, 1.0, 0.0, Float(M_PI_2));
        #else
            wall.rotation = SCNVector4Make(0.0, 1.0, 0.0, CGFloat(M_PI_2));
        #endif
        wall.physicsBody = SCNPhysicsBody.staticBody()
        scene.rootNode.addChildNode(wall)
        
        wall = wall.clone()
        wall.position = SCNVector3Make(202, 50, 0);
        #if os(iOS)
            wall.rotation = SCNVector4Make(0.0, 1.0, 0.0, -Float(M_PI_2));
        #else
            wall.rotation = SCNVector4Make(0.0, 1.0, 0.0, -CGFloat(M_PI_2));
        #endif
        wall.physicsBody = SCNPhysicsBody.staticBody()
        scene.rootNode.addChildNode(wall)
        
        let backWall = SCNNode(geometry:SCNPlane(width:400, height:100))
        backWall.geometry!.firstMaterial = wall.geometry!.firstMaterial;
        backWall.position = SCNVector3Make(0, 50, 198);
        #if os(iOS)
            backWall.rotation = SCNVector4Make(0.0, 1.0, 0.0, Float(M_PI));
        #else
            backWall.rotation = SCNVector4Make(0.0, 1.0, 0.0, CGFloat(M_PI));
        #endif
        backWall.castsShadow = false;
        backWall.physicsBody = SCNPhysicsBody.staticBody()
        scene.rootNode.addChildNode(backWall)

        // add ceil
        let ceilNode = SCNNode(geometry:SCNPlane(width:400, height:400))
        ceilNode.position = SCNVector3Make(0, 100, 0);
        #if os(iOS)
            ceilNode.rotation = SCNVector4Make(1.0, 0.0, 0.0, Float(M_PI_2));
        #else
            ceilNode.rotation = SCNVector4Make(1.0, 0.0, 0.0, CGFloat(M_PI_2));
        #endif
        ceilNode.geometry!.firstMaterial!.doubleSided = false;
        ceilNode.castsShadow = false
        ceilNode.geometry!.firstMaterial!.locksAmbientWithDiffuse = true;
        scene.rootNode.addChildNode(ceilNode)
    }
    
    func addPlayer() {
        let skinnedModelName = "art.scnassets/common/models/explorer/explorer_skinned.dae"
        
        let modelScene = SCNScene(named:skinnedModelName)
        
        let rootNode = modelScene!.rootNode
        
        rootNode.enumerateChildNodesUsingBlock({
            child, stop in
            // do something with node or stop
            if(child.name == "group") {
                self.player = PlayerCharacter(characterNode:child, id:"Player")
                self.player.scale = SCNVector3Make(0.2, 0.2, 0.2)
                self.player.position = SCNVector3Make(-20, 0, -50)
                
                self.scene.rootNode.addChildNode(self.player)
            }
        })
    }
    
    func addEnemies() {
        let skinnedModelName = "art.scnassets/common/models/warrior/walk.dae"
        
        for i in 0...1 {
            let escene = SCNScene(named:skinnedModelName)
            let rootNode = escene!.rootNode
            
            var enemy:EnemyCharacter!

            print("Creating enemy \(i)")
            enemy = EnemyCharacter(characterNode:rootNode, id:"Enemy"+String(i))
            enemy.scale = SCNVector3Make(0.2, 0.2, 0.2)
            #if os(iOS)
                let xPos = 20.0 * Float(i+1)
                let zPos = -40.0 * Float(i+1)
                enemy.rotation = SCNVector4Make(0, 1, 0, Float(M_PI))
                #else
                let xPos = 20.0 * CGFloat(i+1)
                let zPos = -40.0 * CGFloat(i+1)
                enemy.rotation = SCNVector4Make(0, 1, 0, CGFloat(M_PI))
            #endif
            enemy.position = SCNVector3Make(xPos, 0, zPos)

            enemies.append(enemy)
            scene.rootNode.addChildNode(enemy)
        }
        
        /*
        let enemy = EnemyCharacter(characterNode:rootNode, id:"Enemy0")
        enemy.scale = SCNVector3Make(0.2, 0.2, 0.2)
        enemy.position = SCNVector3Make(20, 0, -40)
        #if os(iOS)
            enemy.rotation = SCNVector4Make(0, 1, 0, Float(M_PI))
            #else
            enemy.rotation = SCNVector4Make(0, 1, 0, CGFloat(M_PI))
        #endif
        enemies.append(enemy)
        scene.rootNode.addChildNode(enemy)
        
        
        let escene1 = SCNScene(named:skinnedModelName)
        let rootNode1 = escene1!.rootNode

        let enemy1 = EnemyCharacter(characterNode:rootNode1, id:"Enemy1")
        enemy1.scale = SCNVector3Make(0.2, 0.2, 0.2)
        enemy1.position = SCNVector3Make(40, 0, -40)
        #if os(iOS)
            enemy1.rotation = SCNVector4Make(0, 1, 0, Float(M_PI))
            #else
            enemy1.rotation = SCNVector4Make(0, 1, 0, CGFloat(M_PI))
        #endif
        enemies.append(enemy1)
        scene.rootNode.addChildNode(enemy1)
        */

    }
    
    func renderer(aRenderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        //TEMPORARY - REMOVE THIS WHEN GAME MENUS ARE IMPLEMENTED
        //GameScenesManager.sharedInstance.setGameState(GameState.InGame)
        
        aRenderer.pointOfView = sceneCamera
        currentCamera = sceneCamera

        if(previousTime == 0.0) {
            previousTime = time
        }
        deltaTime = time - previousTime
        previousTime = time
        
        if(GameScenesManager.sharedInstance.gameState == GameState.InGame) {
            player.update(deltaTime)
            for enemy in enemies {
                enemy.update(deltaTime)
            }
            currentCamera.update(deltaTime)
        }

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
        if(nodeName == "cameraNode") {
            currentCamera.turnCameraAroundNode(ship, radius: 175.0, angleInDegrees: -45.0)
        }

    }
}
