//
//  GameCamera.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 6/12/15.
//  Copyright (c) 2015 Vivek Nagar. All rights reserved.
//

import Foundation
import SceneKit
import GLKit
import QuartzCore

enum CameraType :Int {
    case SceneCamera = 0, FPSCamera
}

class GameCamera : SCNNode {
    var cameraType: CameraType!
    var rotationMatrix:SCNMatrix4!
    var slerping:Bool = false
    var slerpCur:Float = 0.0
    let slerpMax:Float = 1.0
    var pos:SCNVector3!
    var slerpStart:SCNVector3!
    var slerpEnd:SCNVector3!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        self.cameraType = CameraType.SceneCamera
        setup()
    }
    
    
    override init() {
        super.init()
        
        self.cameraType = CameraType.SceneCamera
        setup()
    }
    
    init(cameraType:CameraType) {
        super.init()
        
        self.cameraType = cameraType
        setup()
    }

    
    func setup() {
        self.camera = SCNCamera()
        rotationMatrix = SCNMatrix4Identity
        pos = self.position
    }
    
    
    func setupTransformationMatrix() {
        // This is setup one time only to setup update the rotation matrix with camera.rotation
        rotationMatrix = SCNMatrix4Rotate(rotationMatrix, self.rotation.w, self.rotation.x, self.rotation.y, self.rotation.z)
        pos = self.position
        slerpStart = self.position
        slerpEnd = self.position
    }
    
    func lerp(vectorStart:SCNVector3!, vectorEnd:SCNVector3, t:CGFloat) -> SCNVector3
    {
        #if os(iOS)
            let time = Float(t)
        #else
            let time = t
        #endif
        let v = SCNVector3Make(vectorStart.x + ((vectorEnd.x - vectorStart.x) * time),
            vectorStart.y + ((vectorEnd.y - vectorStart.y) * time),
            vectorStart.z + ((vectorEnd.z - vectorStart.z) * time))
        return v;
    }
    
    func update(deltaTime:NSTimeInterval) {
        if (slerping) {
            slerpCur += 0.04;
            var slerpAmt:Float = slerpCur / slerpMax;
            if (slerpAmt > 1.0) {
                slerpAmt = 1.0;
                slerping = false;
                slerpCur = 0.0;
            }
            pos = lerp(slerpStart, vectorEnd: slerpEnd, t: CGFloat(slerpAmt));
            //println("Lerped pos:\(pos.x), \(pos.y), \(pos.z)")
        }
        //println("rotation is \(self.rotation.x), \(self.rotation.y), \(self.rotation.z), \(self.rotation.w)")
        var modelViewMatrix:SCNMatrix4 = SCNMatrix4MakeTranslation(self.pos.x, self.pos.y, self.pos.z)
        modelViewMatrix = SCNMatrix4Mult(rotationMatrix, modelViewMatrix)
        self.transform = modelViewMatrix
        
    }
    
    func yaw(angleInDegrees:Float, duration:CGFloat) {
        #if os(iOS)
            let rotY:Float = Float(angleInDegrees) * Float(M_PI) / 180.0
        #else
            let rotY:CGFloat = CGFloat(angleInDegrees) * CGFloat(M_PI) / 180.0
        #endif
        let invertedMatrix = SCNMatrix4Invert(rotationMatrix)
        let yAxis:SCNVector3 = matrix4MultiplyVector3(invertedMatrix, vectorRight: SCNVector3Make(0, 1, 0))
        rotationMatrix = SCNMatrix4Rotate(rotationMatrix, rotY, yAxis.x, yAxis.y, yAxis.z)
    }
    
    func pitch(angleInDegrees:Float, duration:CGFloat) {
        #if os(iOS)
            let rotX:Float = Float(angleInDegrees) * Float(M_PI) / 180.0
        #else
            let rotX:CGFloat = CGFloat(angleInDegrees) * CGFloat(M_PI) / 180.0
        #endif

        let invertedMatrix = SCNMatrix4Invert(rotationMatrix)
        let yAxis:SCNVector3 = matrix4MultiplyVector3(invertedMatrix, vectorRight: SCNVector3Make(1, 0, 0))
        rotationMatrix = SCNMatrix4Rotate(rotationMatrix, rotX, yAxis.x, yAxis.y, yAxis.z)
    }
    
    func zoom(distance:CGFloat, duration:CGFloat) {
        #if os(iOS)
            let dis:Float = Float(distance)
        #else
            let dis:CGFloat = distance
        #endif
        slerpStart = self.position;
        slerpEnd = SCNVector3Make(self.position.x, self.position.y, self.position.z+dis)
        slerping = true
    }
    
    func matrix4MultiplyVector3(matrixLeft:SCNMatrix4!, vectorRight:SCNVector3) -> SCNVector3
    {
        let v1 = matrixLeft.m11 * vectorRight.x + matrixLeft.m21 * vectorRight.y + matrixLeft.m31 * vectorRight.z
        let v2 = matrixLeft.m12 * vectorRight.x + matrixLeft.m22 * vectorRight.y + matrixLeft.m32 * vectorRight.z
        let v3 = matrixLeft.m13 * vectorRight.x + matrixLeft.m23 * vectorRight.y + matrixLeft.m33 * vectorRight.z
       // let v4:Float = matrixLeft.m14 * vectorRight.x + matrixLeft.m24 * vectorRight.y + matrixLeft.m34 * vectorRight.z
        
        return SCNVector3Make(v1, v2, v3)
    }
    
    func turnCameraAroundNode(node:SCNNode, radius:CGFloat, angleInDegrees:Float)
    {
        let animation = CAKeyframeAnimation(keyPath:"transform")
        animation.duration = 15.0
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        
        var animValues = [NSValue]()
        for var index = 0; index <= 360; ++index {
            let hAngle = Double(index) * M_PI / 180.0
            let vAngle = Double(angleInDegrees) * M_PI / 180.0
            let val = NSValue(CATransform3D: transformationToRotateAroundPosition(node.position, radius:radius, horizontalAngle:CGFloat(hAngle), verticalAngle:CGFloat(vAngle)))
            animValues.append(val)
        }
        
        animation.values = animValues;
        animation.timingFunction = CAMediaTimingFunction (name: kCAMediaTimingFunctionEaseInEaseOut);
        self.addAnimation(animation, forKey:"animation");
        
    }
    
    func transformationToRotateAroundPosition(center:SCNVector3! ,radius:CGFloat, horizontalAngle:CGFloat, verticalAngle:CGFloat) -> CATransform3D
    {
        #if os(iOS)
            let rad:Float = Float(radius)
            let vertAngle:Float = Float(verticalAngle)
            let horAngle:Float = Float(horizontalAngle)
        #else
            let rad:CGFloat = radius
            let vertAngle:CGFloat = verticalAngle
            let horAngle:CGFloat = horizontalAngle
        #endif

        var pos:SCNVector3 = SCNVector3Make(0, 0, 0)
        pos.x = center.x + rad * cos(vertAngle) * sin(horAngle)
        pos.y = self.position.y;
        pos.z = center.z + rad * cos(vertAngle) * cos(horAngle)
        
        let rotX = CATransform3DMakeRotation(CGFloat(verticalAngle), 1, 0, 0)
        let rotY = CATransform3DMakeRotation(CGFloat(horizontalAngle), 0, 1, 0)
        let rotation = CATransform3DConcat(rotX, rotY)
        
        let translate = CATransform3DMakeTranslation(CGFloat(pos.x), CGFloat(pos.y), CGFloat(pos.z))
        let transform = CATransform3DConcat(rotation,translate)
        
        return transform;
    }
    
}
