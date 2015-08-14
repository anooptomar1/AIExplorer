import Foundation
import SceneKit

extension SCNVector3
{
    func vector3DFromSCNVector3() -> Vector3D {
        return Vector3D(x:self.x, y:self.y, z:self.z)
    }
}




