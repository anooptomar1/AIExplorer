//
//  GameViewController.swift
//  MacOSXAIExplorer
//
//  Created by Vivek Nagar on 8/4/15.
//  Copyright (c) 2015 Vivek Nagar. All rights reserved.
//

import SceneKit

class GameViewController: NSViewController {
    
    @IBOutlet weak var gameView: GameView!
    
    override func awakeFromNib(){
        
        let scnView = GameSceneView(frame:gameView!.frame)
        scnView.translatesAutoresizingMaskIntoConstraints = false
        self.gameView!.addSubview(scnView)
        
        // Create a bottom space constraint
        var constraint = NSLayoutConstraint (item: scnView,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.gameView!,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 0)
        // Add the constraint to the view
        self.gameView!.addConstraint(constraint)
        
        // Create a top space constraint
        constraint = NSLayoutConstraint (item: scnView,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.gameView!,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1,
            constant: 0)
        // Add the constraint to the view
        self.gameView!.addConstraint(constraint)
        
        // Create a right space constraint
        constraint = NSLayoutConstraint (item: scnView,
            attribute: NSLayoutAttribute.Right,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.gameView!,
            attribute: NSLayoutAttribute.Right,
            multiplier: 1,
            constant: 0)
        // Add the constraint to the view
        self.gameView!.addConstraint(constraint)
        
        // Create a left space constraint
        constraint = NSLayoutConstraint (item: scnView,
            attribute: NSLayoutAttribute.Left,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.gameView!,
            attribute: NSLayoutAttribute.Left,
            multiplier: 1,
            constant: 0)
        // Add the constraint to the view
        self.gameView!.addConstraint(constraint)


        let scenesMgr = GameScenesManager.sharedInstance
        scenesMgr.setView(scnView)
        
        scenesMgr.setupLevels()
        
    }

}
