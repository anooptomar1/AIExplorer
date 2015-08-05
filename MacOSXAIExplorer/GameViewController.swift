//
//  GameViewController.swift
//  MacOSXAIExplorer
//
//  Created by Vivek Nagar on 8/4/15.
//  Copyright (c) 2015 Vivek Nagar. All rights reserved.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    
    @IBOutlet weak var gameView: GameView!
    
    override func awakeFromNib(){
        
        let scnView = GameSceneView(frame:gameView!.frame)
        self.gameView!.addSubview(scnView)

        let scenesMgr = GameScenesManager.sharedInstance
        scenesMgr.setView(scnView)
        
        scenesMgr.setupLevels()
        
    }

}
