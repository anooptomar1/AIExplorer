//
//  PlayerCharacter.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/6/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import SceneKit

class PlayerCharacter : SkinnedCharacter {
    let assetDirectory = "art.scnassets/common/models/explorer/"
    let skeletonName = "Bip001_Pelvis"
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(characterNode:SCNNode) {
        super.init(rootNode: characterNode)
        
        self.name = "Player"
    }
    
    override func update(deltaTime:NSTimeInterval) {
    }
    
    override func isStatic() -> Bool {
        return false
    }
}
