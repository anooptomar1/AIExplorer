//
//  Vector3D.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/14/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation
import SceneKit


class Vector3D {
    var x:Float!
    var y:Float!
    var z:Float!
    
    init(x:Float, y:Float, z:Float) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    /**
    * Returns the length (magnitude) of the vector described by the SCNVector3
    */
    func length() -> Float {
        return sqrtf(x*x + y*y + z*z)
    }
    
    
    func lengthSquared() -> Float {
        return x*x + y*y + z*z
    }
    
    /**
    * Normalizes the vector described by the SCNVector3 to length 1.0 and returns
    * the result as a new SCNVector3.
    */
    func normalized() -> Vector3D {
        return Vector3D(x: self.x / length(), y: self.y / length(), z: self.z / length())
    }
    
    func scaleBy(scaleFactor:Float) -> Vector3D {
        return Vector3D(x: self.x * scaleFactor, y: self.y * scaleFactor, z: self.z * scaleFactor)
    }
    
    /**
    * Calculates the dot product between two Vector3D's.
    */
    func dot(vector: Vector3D) -> Float {
        return x * vector.x +  y * vector.y + z * vector.z
    }
    
    /**
    * Calculates the cross product between two Vector3D's.
    */
    func cross(vector: Vector3D) -> Vector3D {
        return Vector3D(x:y * vector.z - z * vector.y, y:z * vector.x - x * vector.z, z:x * vector.y - y * vector.x)
    }
    
    func perp() -> Vector3D {
        return Vector3D(x:-self.z, y:self.y, z:self.x)
    }
    
    func truncate(max:Float) -> Vector3D {
        if (self.length() > max) {
            let normalized = self.normalized()
            return Vector3D(x: normalized.x*max, y: normalized.y*max, z:normalized.z*max)
        }
        return self
    }
    
    func getSCNVector3() -> SCNVector3 {
        return SCNVector3Make(self.x, self.y, self.z)
    }
}

func Vector3DEqualToVector3D(currentPosition:Vector3D, targetPosition:Vector3D) -> Bool {
    return ((currentPosition.x == targetPosition.x) && (currentPosition.y == targetPosition.y) && (currentPosition.z == targetPosition.z))
}

