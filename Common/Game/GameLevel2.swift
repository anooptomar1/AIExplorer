//
//  GameLevel2.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/5/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit


class GameLevel2 : NSObject, GameLevel {

    var gameObjects = [String: GameObject]()
    var animationStartTime:CFTimeInterval!
    var ikActive:Bool = false
    var ik:SCNIKConstraint!
    var lookAt:SCNLookAtConstraint!
    var hand:SCNNode!
    
    var scene : SCNScene!
    var scnView : SCNView!
    var previousTime:NSTimeInterval!
    var deltaTime:NSTimeInterval!
    
    var sceneCamera:GameCamera!
    var frontCamera:GameCamera!
    var currentCamera:GameCamera!
    var player:PlayerCharacter!
    var enemy:EnemyCharacter!
    var ship:SCNNode!
    var navMeshPathfinder:Pathfinder!
    
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
        //gameUIManager.setScene(scnView.overlaySKScene!)
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
        
        self.setupSceneElements()
        self.addPlayer()
        //self.addFloorAndWalls()
        self.addEnemies()
        //self.addDebugObjects()

        return self.scene
    }
    
    func setupSceneElements() {
        let bunker = SCNNode()
        let escene = SCNScene(named: "art.scnassets/level2/navmesh.dae", inDirectory: nil, options:nil)
        let rootNode = escene?.rootNode

        rootNode?.enumerateChildNodesUsingBlock({
            child, stop in
            if(child.name == "Navmesh") {
                let triangles = GameUtils.extractVerticesFromSCNNode(child)
                var scaledTriangles:[MeshTriangle] = [MeshTriangle]()
                var idx = 0
                for v in triangles {
                    let scaledTriangle = MeshTriangle()
                    scaledTriangle.vertices.append(Vector3D(x: v.vertices[0].x*25, y: v.vertices[0].y*25, z: v.vertices[0].z*25))
                    scaledTriangle.vertices.append(Vector3D(x: v.vertices[1].x*25, y: v.vertices[1].y*25, z: v.vertices[1].z*25))
                    scaledTriangle.vertices.append(Vector3D(x: v.vertices[2].x*25, y: v.vertices[2].y*25, z: v.vertices[2].z*25))
                    
                    scaledTriangles.append(scaledTriangle)
                    idx++
                }
                self.navMeshPathfinder = NavigationMeshPathfinder(meshTriangles: scaledTriangles)
            }

            bunker.addChildNode(child)
        })
        bunker.position = SCNVector3Make(0, 0, 0)
        bunker.scale = SCNVector3Make(25, 25, 25)
        scene.rootNode.addChildNode(bunker)
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
                self.player.position = SCNVector3Make(0, 0, 120)
                
                self.scene.rootNode.addChildNode(self.player)
                self.gameObjects[self.player.getID()] = self.player
            }
        })
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
    
    
    func addEnemies() {
        let skinnedModelName = "art.scnassets/common/models/warrior/walk.dae"
        let count = 0
        
        for i in 0...count {
            let escene = SCNScene(named:skinnedModelName)
            let rootNode = escene!.rootNode
            hand = rootNode.childNodeWithName("Bip01_R_Hand", recursively: true)
            let clavicle = rootNode.childNodeWithName("Bip01_R_Clavicle", recursively: true)
            let head = rootNode.childNodeWithName("Bip01_Head", recursively:true)

            enemy = EnemyCharacter(characterNode:rootNode, id:"Enemy"+String(i), level:self, pathfinder:self.navMeshPathfinder)
            enemy.scale = SCNVector3Make(enemy.getObjectScale(), enemy.getObjectScale(), enemy.getObjectScale())
            #if os(iOS)
                let xPos = 0.0 * Float(i+1)
                let zPos = -90.0 * Float(i+1)
                enemy.rotation = SCNVector4Make(0, 1, 0, Float(M_PI))
                #else
                let xPos = 0.0 * CGFloat(i+1)
                let zPos = -90.0 * CGFloat(i+1)
                enemy.rotation = SCNVector4Make(0, 1, 0, CGFloat(M_PI))
            #endif
            enemy.position = SCNVector3Make(xPos, 0, zPos)

            scene.rootNode.addChildNode(enemy)
            
            ik = SCNIKConstraint.inverseKinematicsConstraintWithChainRootNode(clavicle!)
            hand!.constraints = [ik];
            ik.influenceFactor = 0.0;

            lookAt = SCNLookAtConstraint(target: self.player)
            head?.constraints = [lookAt]
            lookAt.influenceFactor = 1;
            animationStartTime = CACurrentMediaTime();

        }
        
    }
    
    func renderer(aRenderer: SCNSceneRenderer, didApplyAnimationsAtTime time: NSTimeInterval) {
        if(ikActive) {
    // update the influence factor of the IK constraint based on the animation progress
            let attackSpeed = 1.0
            let animationDuration = 2.0
            var currProgress:CGFloat = CGFloat(attackSpeed * (time - animationStartTime) / animationDuration)
    
            //clamp
            currProgress = max(0,currProgress);
            currProgress = min(1,currProgress);
    
            if(currProgress >= 1){
                ikActive = false
            }
    
            let middle:CGFloat = 0.5
            var f:CGFloat = 0.0
    
            // smoothly increate from 0% to 50% then smoothly decrease from 50% to 100%
            if(currProgress > middle){
                f = (1.0-currProgress)/(1.0-middle);
            }
            else{
                f = currProgress/middle;
            }
    
            ik.influenceFactor = f;
            lookAt.influenceFactor = 1-f;
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
            enemy.update(deltaTime)
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
            enemy!.handleContact(contact.nodeB, gameObjects: gameObjects)
        }
        asRange = contact.nodeB.name!.rangeOfString("EnemyCollideSphere-")
        if let asRange = asRange where asRange.startIndex == contact.nodeB.name!.startIndex {
            enemy!.handleContact(contact.nodeA, gameObjects: gameObjects)
        }

    }

}

//MARK: GameLevel protocol methods
extension GameLevel2 {
    func startLevel() {
    }
    
    func pauseLevel() {
        self.scene.paused = true
    }
    
    func stopLevel() {
        // reset level
    }
    
    func levelFailed() {
        
    }
    func levelCompleted() {
        print("Level completed")
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
        } else if(nodeName == "zoomInNode") {
            ikActive = true
            ik.influenceFactor = 0.9
            animationStartTime = CACurrentMediaTime();
            ik.targetPosition = SCNVector3Make(hand.position.x - 10, hand.position.y - 10 , hand.position.z-10)

        }

    }
}
