//
//  Vector2D.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/8/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation


class Vector2D {
    var x:Float!
    var z:Float!
    
    init(x:Float, z:Float) {
        self.x = x
        self.z = z
    }
    
    /**
    * Returns the length (magnitude) of the vector described by the SCNVector3
    */
    func length() -> Float {
        return sqrtf(x*x + z*z)
    }

    
    func lengthSquared() -> Float {
        return x*x + z*z
    }
    /**
    * Normalizes the vector described by the SCNVector3 to length 1.0 and returns
    * the result as a new SCNVector3.
    */
    func normalized() -> Vector2D {
        return Vector2D(x: self.x / length(), z: self.z / length())
    }
    
    func scaleBy(scaleFactor:Float) -> Vector2D {
        return Vector2D(x: self.x * scaleFactor, z: self.z * scaleFactor)
    }
    /**
    * Calculates the dot product between two SCNVector3.
    */
    func dot(vector: Vector2D) -> Float {
        return x * vector.x +  z * vector.z
    }
    
    
    func perp() -> Vector2D {
        return Vector2D(x:-self.z, z:self.x)
    }
    
    func truncate(max:Float) -> Vector2D {
        if (self.length() > max) {
            let normalized = self.normalized()
            return Vector2D(x: normalized.x*max, z:normalized.z*max)
        }
        return self
    }

}