//
//  EnemyCharacter.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/6/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import SceneKit


class EnemyCharacter : SkinnedCharacter {
    
    let assetDirectory = "art.scnassets/common/models/warrior/"
    let skeletonName = "Bip01"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    init(characterNode:SCNNode, id:String) {
        super.init(rootNode: characterNode)
        self.name = id
    }

    override func update(deltaTime:NSTimeInterval) {
    }
    
    override func isStatic() -> Bool {
        return false
    }
    
    override func getID() -> String {
        return self.name!
    }

}