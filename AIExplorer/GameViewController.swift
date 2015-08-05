//
//  GameViewController.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/4/15.
//  Copyright (c) 2015 Vivek Nagar. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scnView:SCNView = GameSceneView(frame:self.view.frame, options:nil)
        self.view.addSubview(scnView)
        
        let scenesMgr = GameScenesManager.sharedInstance
        scenesMgr.setView(scnView)
        
        scenesMgr.setupLevels()

    }
    
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
