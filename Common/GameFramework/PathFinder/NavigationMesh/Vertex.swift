//
//  Vertex.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/14/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import SceneKit


class Vertex : Equatable, CustomStringConvertible {
    var position:Vector3D!
    
    init(position:Vector3D) {
        self.position = position
    }
    
    //Implement Printable protocol
    var description: String {
        return "vertex coordinates are \(position)"
    }
    
}

func == (lhs: Vertex, rhs: Vertex) -> Bool {
    return lhs.position.x == rhs.position.x && lhs.position.y == rhs.position.y && lhs.position.z == rhs.position.z
}
