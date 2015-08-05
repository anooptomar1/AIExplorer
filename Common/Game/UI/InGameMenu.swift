//
//  InGameMenu.swift
//  SwiftExplorer
//
//  Created by Vivek Nagar on 8/13/14.
//  Copyright (c) 2014 Vivek Nagar. All rights reserved.
//

import SpriteKit

class InGameMenu : SKNode {
    var level:GameLevel!
    var size:CGSize!
    var joystick:Joystick!
    var cameraNode:SKSpriteNode!
    var zoomInNode:SKSpriteNode!
    var zoomOutNode:SKSpriteNode!
    var upNode:SKSpriteNode!
    var downNode:SKSpriteNode!
    var leftNode:SKSpriteNode!
    var rightNode:SKSpriteNode!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    init(size:CGSize, level:GameLevel) {
        super.init()
        
        self.level = level
        self.size = size;
        self.userInteractionEnabled = true
        
        addPlayerControls()
        
        addCameraControls()
    }
    
    func addPlayerControls() {
        let jsThumb:SKSpriteNode = SKSpriteNode(imageNamed: "art.scnassets/ui/joystick")
        let jsBackdrop:SKSpriteNode = SKSpriteNode(imageNamed: "art.scnassets/ui/dpad")
        
        joystick = Joystick(node:jsThumb, backdrop:jsBackdrop)
        joystick.position = CGPointMake(size.width*0.1, size.height*0.1)
        
        joystick.xScale = 0.5
        joystick.yScale = 0.5
        
        self.addChild(joystick);

    }
    
    func addCameraControls() {
        //add the camera button
        cameraNode = SKSpriteNode(imageNamed:"art.scnassets/ui/video_camera")
        cameraNode.position = CGPointMake(size.width * 0.9, size.height*0.9)
        cameraNode.name = "cameraNode"
        cameraNode.xScale = 0.4
        cameraNode.yScale = 0.4
        self.addChild(cameraNode)
        
        
        upNode = SKSpriteNode(imageNamed:"art.scnassets/ui/arrow-up");
        upNode.size = CGSizeMake(20, 20);
        upNode.position = CGPointMake(size.width*0.2, size.height*0.9);
        upNode.name = "pitchUpNode";//how the node is identified later
        upNode.zPosition = 1.0;
        self.addChild(upNode);
        
        downNode = SKSpriteNode(imageNamed:"art.scnassets/ui/arrow-down");
        downNode.size = CGSizeMake(20, 20);
        downNode.position = CGPointMake(size.width*0.2, size.height*0.8);
        downNode.name = "pitchDownNode";//how the node is identified later
        downNode.zPosition = 1.0;
        self.addChild(downNode);

        leftNode = SKSpriteNode(imageNamed:"art.scnassets/ui/arrow-left");
        leftNode.size = CGSizeMake(20, 20);
        leftNode.position = CGPointMake(size.width*0.1, size.height*0.85);
        leftNode.name = "yawLeftNode";//how the node is identified later
        leftNode.zPosition = 1.0;
        self.addChild(leftNode);
        
        rightNode = SKSpriteNode(imageNamed:"art.scnassets/ui/arrow-right");
        rightNode.size = CGSizeMake(20, 20);
        rightNode.position = CGPointMake(size.width*0.3, size.height*0.85);
        rightNode.name = "yawRightNode";//how the node is identified later
        rightNode.zPosition = 1.0;
        self.addChild(rightNode);
        
        
        zoomInNode = SKSpriteNode(imageNamed:"art.scnassets/ui/arrow-up");
        zoomInNode.size = CGSizeMake(20, 20);
        zoomInNode.position = CGPointMake(size.width*0.4, size.height*0.9);
        zoomInNode.name = "zoomInNode";//how the node is identified later
        zoomInNode.zPosition = 1.0;
        self.addChild(zoomInNode);
        
        zoomOutNode = SKSpriteNode(imageNamed:"art.scnassets/ui/arrow-down");
        zoomOutNode.size = CGSizeMake(20, 20);
        zoomOutNode.position = CGPointMake(size.width*0.4, size.height*0.8);
        zoomOutNode.name = "zoomOutNode";//how the node is identified later
        zoomOutNode.zPosition = 1.0;
        self.addChild(zoomOutNode);


    }
    
    #if os(iOS)
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch:UITouch = touches.first as UITouch!
        let location:CGPoint = touch.locationInNode(scene!)
        let node:SKNode = scene!.nodeAtPoint(location)
        if let name = node.name { // Check if node name is not nil
            level.buttonPressedAction(name)
        }
    }
    #else
    override func mouseDown(event:NSEvent)
    {
        let location:CGPoint = event.locationInNode(self)
        let node:SKNode = scene!.nodeAtPoint(location)
        if let name = node.name { // Check if node name is not nil
            level.buttonPressedAction(name)
        }
    }
    #endif
    

}