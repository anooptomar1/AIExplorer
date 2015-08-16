//
//  GameLevel.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 6/9/15.
//  Copyright (c) 2015 Vivek Nagar. All rights reserved.
//

import Foundation

import SceneKit
import SpriteKit


protocol GameLevel : SCNSceneRendererDelegate, SCNPhysicsContactDelegate {
    func createLevel(scnView:SCNView) -> SCNScene
    func startLevel()
    func pauseLevel()
    func stopLevel()
    
    func levelFailed()
    func levelCompleted()
    
    func getGameObject(id:String) -> GameObject
    func changeUIState(state:GameState)
    func buttonPressedAction(nodeName:String)
}
