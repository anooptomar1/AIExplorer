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

enum ColliderType: Int {
    case Ground = 1024
    case RacingCar = 4
    case Player = 8
    case Enemy = 16
    case LeftWall = 32
    case RightWall = 64
    case BackWall = 128
    case FrontWall = 256
    case Door = 512
    
}

class GameLevel0 : NSObject, GameLevel {

    var gameObjects = [String: GameObject]()
    
    var scene : SCNScene!
    var scnView : SCNView!
    var previousTime:NSTimeInterval!
    var deltaTime:NSTimeInterval!
    
    var sceneCamera:GameCamera!
    var frontCamera:GameCamera!
    var currentCamera:GameCamera!
    var player:PlayerCharacter!
    var enemies = [String: EnemyCharacter]()
    var ship:SCNNode!
    
    override init() {
        super.init()
        
        previousTime = 0.0
        deltaTime = 0.0
    }
    
    
    func createLevel(scnView:SCNView) -> SCNScene {
        self.scnView = scnView
        // create a new scene
        //self.scene = SCNScene(named: "art.scnassets/level0/ship.dae")!
        self.scene = SCNScene()
        
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
        self.addObstacles()
        self.addDebugObjects()

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
        wall.name = "FrontWall"
        wall.physicsBody = SCNPhysicsBody.staticBody()
        wall.physicsBody!.collisionBitMask = ColliderType.Player.rawValue | ColliderType.Enemy.rawValue
        wall.physicsBody!.categoryBitMask = ColliderType.FrontWall.rawValue
        scene.rootNode.addChildNode(wall)
        
        wall = wall.clone()
        wall.position = SCNVector3Make(-202, 50, 0);
        wall.name = "LeftWall"
        wall.rotation = SCNVector4Make(0.0, 1.0, 0.0, GFloat(M_PI_2));
        wall.physicsBody = SCNPhysicsBody.staticBody()
        wall.physicsBody!.collisionBitMask = ColliderType.Player.rawValue | ColliderType.Enemy.rawValue
        wall.physicsBody!.categoryBitMask = ColliderType.LeftWall.rawValue
        scene.rootNode.addChildNode(wall)
        
        wall = wall.clone()
        wall.position = SCNVector3Make(202, 50, 0);
        wall.name = "RightWall"
        wall.rotation = SCNVector4Make(0.0, 1.0, 0.0, -GFloat(M_PI_2));
        wall.physicsBody = SCNPhysicsBody.staticBody()
        wall.physicsBody!.collisionBitMask = ColliderType.Player.rawValue | ColliderType.Enemy.rawValue
        wall.physicsBody!.categoryBitMask = ColliderType.RightWall.rawValue
        scene.rootNode.addChildNode(wall)
        
        let backWall = SCNNode(geometry:SCNPlane(width:400, height:100))
        backWall.name = "BackWall"
        backWall.geometry!.firstMaterial = wall.geometry!.firstMaterial;
        backWall.position = SCNVector3Make(0, 50, 198);
        backWall.rotation = SCNVector4Make(0.0, 1.0, 0.0, GFloat(M_PI));
        backWall.castsShadow = false;
        backWall.physicsBody = SCNPhysicsBody.staticBody()
        wall.physicsBody!.collisionBitMask = ColliderType.Player.rawValue | ColliderType.Enemy.rawValue
        wall.physicsBody!.categoryBitMask = ColliderType.BackWall.rawValue
        scene.rootNode.addChildNode(backWall)

        // add ceiling
        let ceilNode = SCNNode(geometry:SCNPlane(width:400, height:400))
        ceilNode.position = SCNVector3Make(0, 100, 0);
        ceilNode.rotation = SCNVector4Make(1.0, 0.0, 0.0, GFloat(M_PI_2));
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
                self.player = PlayerCharacter(characterNode:child, id:"Player", level:self)
                self.player.scale = SCNVector3Make(self.player.getObjectScale(), self.player.getObjectScale(), self.player.getObjectScale())
                self.player.position = SCNVector3Make(-20, 0, -50)
                
                self.scene.rootNode.addChildNode(self.player)
                self.gameObjects[self.player.getID()] = self.player
            }
        })
    }
    
    func addEnemies() {
        let skinnedModelName = "art.scnassets/common/models/warrior/walk.dae"
        let count = 0
        
        for i in 0...count {
            let escene = SCNScene(named:skinnedModelName)
            let rootNode = escene!.rootNode
            
            var enemy:EnemyCharacter!

            enemy = EnemyCharacter(characterNode:rootNode, id:"Enemy"+String(i), level:self)
            enemy.scale = SCNVector3Make(enemy.getObjectScale(), enemy.getObjectScale(), enemy.getObjectScale())
            #if os(iOS)
                let xPos = 10.0 * Float(i+1)
                let zPos = 100.0 * Float(i+1)
                enemy.rotation = SCNVector4Make(0, 1, 0, Float(M_PI))
                #else
                let xPos = 10.0 * CGFloat(i+1)
                let zPos = 100.0 * CGFloat(i+1)
                enemy.rotation = SCNVector4Make(0, 1, 0, CGFloat(M_PI))
            #endif
            enemy.position = SCNVector3Make(xPos, 0, zPos)

            enemies[enemy.getID()] = enemy
            //enemies.append(enemy)
            scene.rootNode.addChildNode(enemy)
            self.gameObjects[enemy.getID()] = enemy
        }
        
    }
    
    func getGameObject(id:String) -> GameObject {
        return gameObjects[id]!
    }
    
    func addDebugObjects() {
        #if os(iOS)
        GameUtilities.createDebugBox(self.scene, box:SCNBox(width:5.0, height:5.0, length:5.0, chamferRadius:1.0), position: SCNVector3Make(0.0, 0.0, 100.0), color: SKColor.redColor(), rotation:SCNVector4Make(Float(1.0), Float(0.0), Float(0.0), Float(0.0)))
        #else
            GameUtilities.createDebugBox(self.scene, box:SCNBox(width:5.0, height:5.0, length:5.0, chamferRadius:1.0), position: SCNVector3Make(0.0, 0.0, 100.0), color: SKColor.redColor(), rotation:SCNVector4Make(CGFloat(1.0), CGFloat(0.0), CGFloat(0.0), CGFloat(0.0)))
        #endif
    }
    
    func addObstacles() {
        let boxObstacle = BoxObstacle()
        boxObstacle.position = SCNVector3Make(-120, 0, 20)
        boxObstacle.rotation = SCNVector4Make(0, 1, 0, GFloat(M_PI_2))
        scene.rootNode.addChildNode(boxObstacle)
        
        // Add torch to list of game objects
        gameObjects[boxObstacle.getID()] = boxObstacle
    }
    
    func renderer(aRenderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        aRenderer.pointOfView = sceneCamera
        currentCamera = sceneCamera

        if(previousTime == 0.0) {
            previousTime = time
        }
        deltaTime = time - previousTime
        previousTime = time
        
        if(GameScenesManager.sharedInstance.gameState == GameState.InGame) {
            player.update(deltaTime)
            for (_, enemy) in enemies {
                enemy.update(deltaTime)
            }
            currentCamera.update(deltaTime)
        }

    }

    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        print("Contact between nodes: \(contact.nodeA.name) and \(contact.nodeB.name)")
        if(contact.nodeA.name == "PlayerCollideSphere") {
            player.handleContact(contact.nodeB, gameObjects: gameObjects)
        }
        if( contact.nodeB.name == "PlayerCollideSphere") {
            player.handleContact(contact.nodeA, gameObjects: gameObjects)
        }
        var asRange = contact.nodeA.name!.rangeOfString("EnemyCollideSphere-")
        if let asRange = asRange where asRange.startIndex == contact.nodeA.name!.startIndex {
            let substr = contact.nodeA.name!.substringFromIndex(advance(contact.nodeA.name!.startIndex, 19))
            //print("substr is \(substr)")
            let enemy = enemies[substr]
            enemy!.handleContact(contact.nodeB, gameObjects: gameObjects)
        }
        asRange = contact.nodeB.name!.rangeOfString("EnemyCollideSphere-")
        if let asRange = asRange where asRange.startIndex == contact.nodeB.name!.startIndex {
            let substr = contact.nodeB.name!.substringFromIndex(advance(contact.nodeB.name!.startIndex, 19))
            //print("substr is \(substr)")
            let enemy = enemies[substr]
            enemy!.handleContact(contact.nodeA, gameObjects: gameObjects)
        }

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
            currentCamera.turnCameraAroundNode(player, radius: 175.0, angleInDegrees: -45.0)
        }

    }
}
