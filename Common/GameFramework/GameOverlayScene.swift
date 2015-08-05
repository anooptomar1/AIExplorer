//
//  GameOverlayScene.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/12/14.
//  Copyright (c) 2014 Vivek Nagar. All rights reserved.
//

import SpriteKit

class GameOverlayScene : SKScene {

    override init() {
        super.init()
        setup()
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup () {
        self.scaleMode = SKSceneScaleMode.ResizeFill
    }
    
    override func didChangeSize(oldSize: CGSize) {
        //print("Did change size")

        /*
        for node in self.children {
        }
        */
    }
}