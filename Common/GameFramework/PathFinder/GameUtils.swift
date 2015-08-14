//
//  GameEffects.swift
//  SwiftExplorer
//
//  Created by Vivek Nagar on 8/17/14.
//  Copyright (c) 2014 Vivek Nagar. All rights reserved.
//

import SceneKit

class GameUtils {
    let EPSILON:Float = 0.001
    let EPSILON_SQUARE:Float = 0.001*0.001

    func side(v1:Vector3D, v2:Vector3D, v:Vector3D) -> Float
    {
        return (v2.z - v1.z)*(v.x - v1.x) + (-v2.x + v1.x)*(v.z - v1.z)
    }
    
    func naivePointInTriangle(v1:Vector3D, v2:Vector3D, v3:Vector3D, v:Vector3D) -> Bool
    {
        let checkSide1:Bool = side(v1, v2:v2, v:v) >= 0
        let checkSide2:Bool = side(v2, v2:v3, v:v) >= 0
        let checkSide3:Bool = side(v3, v2:v1, v:v) >= 0
        return checkSide1 && checkSide2 && checkSide3;
    }
    
    func pointInTriangleBoundingBox(v1:Vector3D, v2:Vector3D, v3:Vector3D, v:Vector3D) -> Bool
    {
        let xMin:Float = min(v1.x, min(v2.x, v3.x)) - EPSILON;
        let xMax:Float = max(v1.x, max(v2.x, v3.x)) + EPSILON;
        let zMin:Float = min(v1.z, min(v2.z, v3.z)) - EPSILON;
        let zMax:Float = max(v1.z, max(v2.z, v3.z)) + EPSILON;
        
        if ( v.x < xMin || xMax < v.x || v.z < zMin || zMax < v.z) {
            return false
        }
        else {
            return true
        }
    }

    func distanceSquarePointToSegment(v1:Vector3D, v2:Vector3D, v:Vector3D) -> Float
    {
        let p1_p2_squareLength:Float = (v2.x - v1.x)*(v2.x - v1.x) + (v2.z - v1.z)*(v2.z - v1.z)
        let dotProduct:Float = ((v.x - v1.x)*(v2.x - v1.x) + (v.z - v1.z)*(v2.z - v1.z)) / p1_p2_squareLength;
        if ( dotProduct < 0 )
        {
            return (v.x - v1.x)*(v.x - v1.x) + (v.z - v1.z)*(v.z - v1.z);
        }
        else if ( dotProduct <= 1 )
        {
            let p_p1_squareLength:Float = (v1.x - v.x)*(v1.x - v.x) + (v1.z - v.z)*(v1.z - v.z);
            return p_p1_squareLength - dotProduct * dotProduct * p1_p2_squareLength;
        }
        else
        {
            return (v.x - v2.x)*(v.x - v2.x) + (v.z - v2.z)*(v.z - v2.z)
        }
    }
    
    func accuratePointInTriangle(v1:Vector3D, v2:Vector3D, v3:Vector3D, v:Vector3D) -> Bool
    {
        if (!pointInTriangleBoundingBox(v1, v2: v2, v3: v3, v: v)) {
            return false
        }
        if (naivePointInTriangle(v1, v2: v2, v3: v3, v: v)) {
            return true
        }
        if (distanceSquarePointToSegment(v1, v2: v2, v: v) <= EPSILON_SQUARE) {
            return true
        }
        if (distanceSquarePointToSegment(v2, v2: v3, v: v) <= EPSILON_SQUARE) {
            return true
        }
        if (distanceSquarePointToSegment(v3, v2: v1, v: v) <= EPSILON_SQUARE) {
            return true
        }
        
        return false;
    }



    class func extractVerticesFromSCNNode(node:SCNNode) -> [MeshTriangle] {
        var triangles:[MeshTriangle] = [MeshTriangle]()
        
        let geometry = node.geometry
        // Get the vertex sources
        let vertexSources = geometry?.geometrySourcesForSemantic(SCNGeometrySourceSemanticVertex)
    
    // Get the first source
        let vertexSource = vertexSources?[0]; // TODO: Parse all the sources
    
        let stride = vertexSource!.dataStride; // in bytes
        let offset = vertexSource!.dataOffset; // in bytes
    
        let componentsPerVector = vertexSource!.componentsPerVector;
        let bytesPerVector = componentsPerVector * vertexSource!.bytesPerComponent;
        let vectorCount = vertexSource!.vectorCount;
    
        var vertices:[Vector3D] = [Vector3D]()
    
        // for each vector, read the bytes
        for i in 0...vectorCount-1 {
            // Assuming that bytes per component is 4 (a float)
            // If it was 8 then it would be a double (aka CGFloat)
            var vectorData = [Float](count:componentsPerVector, repeatedValue:0.0)
    
            // The range of bytes for this vector
            let byteRange = NSMakeRange(i*stride + offset, // Start at current stride + offset
                                        bytesPerVector);   // and read the lenght of one vector
    
            // Read into the vector data buffer
            vertexSource!.data.getBytes(&vectorData, range:byteRange)
    
            // At this point you can read the data from the float array
            let x = vectorData[0];
            let y = vectorData[1];
            let z = vectorData[2];
    
            // ... Maybe even save it as an SCNVector3 for later use ...
            vertices.append(Vector3D(x:x, y:y, z:z))
    
            // ... or just log it
            //print("x:\(x), y:\(y), z:\(z)")
            
            
        }
        
        let geoElementCount = geometry?.geometryElementCount
        print("geo element count is \(geoElementCount)")
        
        for j in 0 ... geoElementCount!-1 {
            let primitiveElement = geometry?.geometryElementAtIndex(j)
            print("primitive type : \(primitiveElement?.primitiveType.rawValue), primitive count is \(primitiveElement?.primitiveCount)")
            print("Data length:\(primitiveElement!.data.length), bytesPerIndex:\(primitiveElement!.bytesPerIndex)")
            
            for var index=0; index<primitiveElement!.data.length; index += primitiveElement!.bytesPerIndex * 3 {
                var buff = [Int](count:3, repeatedValue:0)
                
                primitiveElement!.data.getBytes(&buff, range:NSMakeRange(index, primitiveElement!.bytesPerIndex))
                primitiveElement!.data.getBytes(&buff[1], range:NSMakeRange(index + primitiveElement!.bytesPerIndex, primitiveElement!.bytesPerIndex))
                primitiveElement!.data.getBytes(&buff[2], range:NSMakeRange(index + primitiveElement!.bytesPerIndex * 2, primitiveElement!.bytesPerIndex))
             
                //print("a:\(buff[0]), b:\(buff[1]), c:\(buff[2])")
                let x1 = buff[0]
                let x2 = buff[1]
                let x3 = buff[2]
                //print("triangle pt a:\(vertices[x1]), b:\(vertices[x2]), c:\(vertices[x3])")
                
                let t = MeshTriangle()
                t.vertices.append(vertices[x1])
                t.vertices.append(vertices[x2])
                t.vertices.append(vertices[x3])
                
                triangles.append(t)

            }
        }
        return triangles
    }
}

