//
//  MeshTriangle.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/14/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import SceneKit

class MeshTriangle {
    var vertices:[Vector3D] = [Vector3D]()
    
    func hasVertex(position:Vector3D) -> Bool {
        let vertex0 = vertices[0]
        let vertex1 = vertices[1]
        let vertex2 = vertices[2]
        
        if((vertex0.x == position.x) && (vertex0.y == position.y) && (vertex0.z == position.z)) {
            return true
        }
        if((vertex1.x == position.x) && (vertex1.y == position.y) && (vertex1.z == position.z)) {
            return true
        }
        if((vertex2.x == position.x) && (vertex2.y == position.y) && (vertex2.z == position.z)) {
            return true
        }
        
        return false
    }
}
