//
//  BoxObstacle.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/10/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import SceneKit
import SpriteKit

class BoxObstacle : SCNNode, GameObject {
    
    var boundingRadius:Float = 0.0
    var objScale:GFloat = 1.0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override init() {
        super.init()
        self.name = "BoxObstacle"
        let geometry = SCNBox(width: 80, height: 60, length: 10, chamferRadius: 0)
        geometry.firstMaterial!.diffuse.contents = SKColor.brownColor()
        self.geometry = geometry
        
        boundingRadius = Float(objScale) * Float(geometry.width/2.0)

    }
}

extension BoxObstacle {
    func getID() -> String {
        return self.name!
    }
    
    func update(deltaTime:NSTimeInterval) {
        
    }
    
    func isStatic() -> Bool {
        return true
    }
    
    func getObjectScale() -> GFloat {
        return self.objScale
    }
    
    func getObjectPosition() -> SCNVector3 {
        return self.position
    }
    
    func getBoundingRadius() -> Float {
        return self.boundingRadius
    }

}