//
//  GameSceneView.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/4/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//


import SceneKit


class GameSceneView: SCNView {
    
    let LeftKey = "LeftKey"
    let RightKey = "RightKey"
    let JumpKey = "JumpKey"
    let RunKey = "RunKey"
    
    var keysPressed = Set<String>()

    // Keyspressed is our set of current inputs
    func updateKey(key: String, isPressed:Bool)
    {
        if (isPressed) {
            keysPressed.insert(key)
        } else {
            keysPressed.remove(key)
        }
    }

#if os(iOS)
    
    override init(frame: CGRect, options: [String : AnyObject]?) {
        super.init(frame:frame, options:options)
        print("Initializing GameSceneView")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    
        return true
    }
    
    
#else
    
    override var acceptsFirstResponder : Bool { get { return true } }

    
    override func keyDown(theEvent: NSEvent) {

        
        //print("Key code is \(theEvent.keyCode)")
        switch (theEvent.keyCode) {
            case 124:
                self.updateKey(RightKey, isPressed:false)
                break;
            case 123:
                self.updateKey(LeftKey, isPressed:false)
                break;
            case 125:
                self.updateKey(RunKey, isPressed:false)
                break;
            case 126:
                self.updateKey(JumpKey, isPressed:false)
                break;
            default:
                break;
        }
        
        super.keyDown(theEvent)
    }
    
    override func keyUp(theEvent: NSEvent) {

        
        switch (theEvent.keyCode) {
            case 124:
                self.updateKey(RightKey, isPressed:false)
                break;
            case 123:
                self.updateKey(LeftKey, isPressed:false)
                break;
            case 125:
                self.updateKey(RunKey, isPressed:false)
                break;
            case 126:
                self.updateKey(JumpKey, isPressed:false)
                break;
            default:
                break;
        }
        
        super.keyUp(theEvent)
    
    }
    
    
    override func mouseUp(theEvent: NSEvent) {
    
        super.mouseUp(theEvent)
    }
    
    #endif

}
