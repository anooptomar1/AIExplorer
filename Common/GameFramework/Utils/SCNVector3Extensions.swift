import Foundation
import SceneKit

extension SCNVector3
{
    func vector3DFromSCNVector3() -> Vector3D {
        return Vector3D(x:Float(self.x), y:Float(self.y), z:Float(self.z))
    }
}




