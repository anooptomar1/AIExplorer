//
//  NavigationMeshGraph.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/14/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import SceneKit

class NavigationMeshGraph {
    var triangles:[MeshTriangle]
    var nodeGraph: UnweightedGraph<Vertex> = UnweightedGraph<Vertex>()
    
    init(v:[MeshTriangle]) {
        var v1:Vertex!
        var v2:Vertex!
        var v3:Vertex!
        var newV1:Bool = false
        var newV2:Bool = false
        var newV3:Bool = false
        
        self.triangles = v

        //print("Creating Nav mesh graph with triangle count:\(self.triangles.count)")

        if(self.triangles.count > 0) {
            for i in 0...self.triangles.count-1 {
                //print("Triangle:\(i), vertices:\(triangles[i].vertices[0]), \(triangles[i].vertices[1]), \(triangles[i].vertices[2])")
                v1 = Vertex(position: triangles[i].vertices[0])
                let a = nodeGraph.indexOfVertex(v1)
                if(a == nil) {
                    // new node
                    nodeGraph.addVertex(v1)
                    newV1 = true
                } else {
                    v1 = nodeGraph.vertexAtIndex(a!)
                }
                
                v2 = Vertex(position: triangles[i].vertices[1])
                let b = nodeGraph.indexOfVertex(v2)
                if(b == nil) {
                    // new node
                    nodeGraph.addVertex(v2)
                    newV2 = true
                } else {
                    v2 = nodeGraph.vertexAtIndex(b!)
                }
                
                v3 = Vertex(position: triangles[i].vertices[2])
                let c = nodeGraph.indexOfVertex(v3)
                if(c == nil) {
                    // new node
                    nodeGraph.addVertex(v3)
                    newV3 = true
                } else {
                    v3 = nodeGraph.vertexAtIndex(c!)
                }
                
                // Add edges
                if(newV1 || newV2) {
                    nodeGraph.addEdge(v1, to:v2)
                }
                if(newV2 || newV3) {
                    nodeGraph.addEdge(v2, to:v3)
                }
                if(newV3 || newV1) {
                    nodeGraph.addEdge(v3, to:v1)
                }
            }
        } else {
            // Test data
            v1 = Vertex(position: Vector3D(x: -100,y: 0, z: -100))
            nodeGraph.addVertex(v1)
            v2 = Vertex(position: Vector3D(x: 0,y: 0, z: 100))
            nodeGraph.addVertex(v2)
            v3 = Vertex(position: Vector3D(x: 100,y: 0, z: -100))
            nodeGraph.addVertex(v3)
            // Add edges
            nodeGraph.addEdge(v1, to:v2)
            nodeGraph.addEdge(v2, to:v3)
            nodeGraph.addEdge(v3, to:v1)
            
        }
        //self.printGraph()
    }
    
    func printGraph() {
        print("NODE GRAPH: \(self.nodeGraph)")
    }
    
}
