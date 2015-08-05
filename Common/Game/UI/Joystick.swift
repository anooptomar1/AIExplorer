//
//  Joystick.swift
//  SwiftExplorer
//
//  Created by Vivek Nagar on 8/13/14.
//  Copyright (c) 2014 Vivek Nagar. All rights reserved.
//

import SpriteKit

class Joystick : SKNode {
    var thumbNode : SKSpriteNode!
    var velocity : CGPoint!
    var travelLimit : CGPoint!
    var angularVelocity: Float!
    var size: Float!
    var isTracking: Bool!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    init(node:SKSpriteNode) {
        super.init()
    
        self.userInteractionEnabled = true
        velocity = CGPointZero
        isTracking = false
        thumbNode = node
        self.addChild(thumbNode)
    
    }
    
    init(node:SKSpriteNode, backdrop:SKSpriteNode) {
        super.init()
        
        self.userInteractionEnabled = true
        velocity = CGPointZero
        isTracking = false
        thumbNode = node
        self.addChild(thumbNode)
        
        backdrop.position = self.anchorPointInPoints()
        self.size = Float(backdrop.size.width)
        self.addChild(backdrop)
        
    }
    
    func anchorPointInPoints() -> CGPoint {
        return  CGPointMake(0, 0)
    }
    
    func resetVelocity() {
        isTracking = false;
        velocity = CGPointZero;
        angularVelocity = 0.0;
        let easeOut:SKAction = SKAction.moveTo(self.anchorPointInPoints(), duration: 0.3)
        easeOut.timingMode = SKActionTimingMode.EaseOut;
        thumbNode.runAction(easeOut);
    }

    #if os(iOS)
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touche in touches
        {
            let touch = touche as UITouch
            let touchPoint:CGPoint = touch.locationInNode(self);
            if (isTracking == false && CGRectContainsPoint(thumbNode.frame, touchPoint))
            {
                isTracking = true;
            }
        }
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touche in touches
        {
            let touch = touche as UITouch

            let touchPoint:CGPoint = touch.locationInNode(self)
            
            if (isTracking == true && sqrtf(powf(Float(touchPoint.x - thumbNode.position.x), 2) + powf(Float(touchPoint.y - thumbNode.position.y), 2)) < size * 2)
            {
                
                if (sqrtf(powf(Float(touchPoint.x - self.anchorPointInPoints().x), 2) + powf(Float(touchPoint.y - self.anchorPointInPoints().y), 2)) <= Float(thumbNode.size.width))
                {
                    let moveDifference:CGPoint = CGPointMake(touchPoint.x - self.anchorPointInPoints().x, touchPoint.y - self.anchorPointInPoints().y)
    
                    thumbNode.position = CGPointMake(self.anchorPointInPoints().x + moveDifference.x, self.anchorPointInPoints().y + moveDifference.y)
                }
                else
                {
                    let vX:Double = Double(touchPoint.x - self.anchorPointInPoints().x)
                    let vY:Double = Double(touchPoint.y - self.anchorPointInPoints().y)
                    let magV:Double = sqrt(vX*vX + vY*vY);
                    let aX:Double = Double(self.anchorPointInPoints().x) + vX / magV * Double(thumbNode.size.width)
                    let aY:Double = Double(self.anchorPointInPoints().y) + vY / magV * Double(thumbNode.size.width)
                    
                    thumbNode.position = CGPointMake(CGFloat(aX), CGFloat(aY))
                }
            }
            velocity = CGPointMake(((thumbNode.position.x - self.anchorPointInPoints().x)), ((thumbNode.position.y - self.anchorPointInPoints().y)));
            
            angularVelocity = -atan2(Float(thumbNode.position.x - self.anchorPointInPoints().x), Float(thumbNode.position.y - self.anchorPointInPoints().y))
        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        resetVelocity()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        resetVelocity()
    }
    
    #else
    override func mouseUp(event:NSEvent) {
        isTracking = false;
    
        self.resetVelocity()
    }
    
    override func mouseDown(theEvent:NSEvent) {
        let touchPoint = theEvent.locationInNode(self)
    
        if (isTracking == false && CGRectContainsPoint(thumbNode.frame, touchPoint))
        {
            isTracking = true;
        }
    
    
        super.mouseDown(theEvent)
    }
    
    override func mouseDragged(theEvent:NSEvent)
    {        
        let touchPoint = theEvent.locationInNode(self)

        if (isTracking == true && sqrtf(powf(Float(touchPoint.x - thumbNode.position.x), 2) + powf(Float(touchPoint.y - thumbNode.position.y), 2)) < size * 2)
        {
            
            if (sqrtf(powf(Float(touchPoint.x - self.anchorPointInPoints().x), 2) + powf(Float(touchPoint.y - self.anchorPointInPoints().y), 2)) <= Float(thumbNode.size.width))
            {
                let moveDifference:CGPoint = CGPointMake(touchPoint.x - self.anchorPointInPoints().x, touchPoint.y - self.anchorPointInPoints().y)
                // NSLog(@"Moving thumb to %f,%f", self.anchorPointInPoints.x +moveDifference.x, self.anchorPointInPoints.y+moveDifference.y);
                
                thumbNode.position = CGPointMake(self.anchorPointInPoints().x + moveDifference.x, self.anchorPointInPoints().y + moveDifference.y)
            }
            else
            {
                let vX:Double = Double(touchPoint.x - self.anchorPointInPoints().x)
                let vY:Double = Double(touchPoint.y - self.anchorPointInPoints().y)
                let magV:Double = sqrt(vX*vX + vY*vY);
                let aX:Double = Double(self.anchorPointInPoints().x) + vX / magV * Double(thumbNode.size.width)
                let aY:Double = Double(self.anchorPointInPoints().y) + vY / magV * Double(thumbNode.size.width)
                
                thumbNode.position = CGPointMake(CGFloat(aX), CGFloat(aY))
            }
        }
        velocity = CGPointMake(((thumbNode.position.x - self.anchorPointInPoints().x)), ((thumbNode.position.y - self.anchorPointInPoints().y)));
        
        angularVelocity = -atan2(Float(thumbNode.position.x - self.anchorPointInPoints().x), Float(thumbNode.position.y - self.anchorPointInPoints().y))
        
        print("velocity is \(velocity) and angular velocity is \(angularVelocity)")
    }

    #endif
    
}
