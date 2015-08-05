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


@objc protocol GameLevel : SCNSceneRendererDelegate, SCNPhysicsContactDelegate {
    func createLevel(scnView:SCNView) -> SCNScene
    func startLevel()
    func pauseLevel()
    func stopLevel()
    
    func changeUIState(state:GameState)
    func buttonPressedAction(nodeName:String)
}
