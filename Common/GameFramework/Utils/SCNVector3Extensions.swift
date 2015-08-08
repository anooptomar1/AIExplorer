import Foundation
import SceneKit

extension SCNVector3
{
    
    /**
     * Returns the length (magnitude) of the vector described by the SCNVector3
     */
    func length() -> Float {
        #if os(iOS)
            return sqrtf(x*x + y*y + z*z)
        #else
            return sqrtf(Float(x)*Float(x) + Float(y)*Float(y) + Float(z)*Float(z))
        #endif
    }
    
    /**
     * Normalizes the vector described by the SCNVector3 to length 1.0 and returns
     * the result as a new SCNVector3.
     */
    func normalized() -> SCNVector3 {
        #if os(iOS)
            return SCNVector3Make(self.x / length(), self.y / length(), self.z / length())
        #else
            return SCNVector3Make(self.x / CGFloat(length()), self.y / CGFloat(length()), self.z / CGFloat(length()))
        #endif
    }
    
    /**
     * Normalizes the vector described by the SCNVector3 to length 1.0.
     */
    mutating func normalize() -> SCNVector3 {
        self = normalized()
        return self
    }
    
    
    /**
     * Calculates the dot product between two SCNVector3.
     */
    func dot(vector: SCNVector3) -> Float {
        #if os(iOS)
            return x * vector.x + y * vector.y + z * vector.z
        #else
            return Float(x * vector.x + y * vector.y + z * vector.z)
        #endif
    }
    
    /**
     * Calculates the cross product between two SCNVector3.
     */
    func cross(vector: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(y * vector.z - z * vector.y, z * vector.x - x * vector.z, x * vector.y - y * vector.x)
    }
}




