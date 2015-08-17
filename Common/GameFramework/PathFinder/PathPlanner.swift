//
//  PathPlanner.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/14/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import SceneKit

class PathPlanner {
    var pathfinder:Pathfinder!
    var owner:MovingGameObject!
    private var targetPosition:Vector3D!
    private var originalPosition:Vector3D!
    
    var shortestPath = [ShortestPathStep]()

    
    init(owner:MovingGameObject, pathfinder:Pathfinder) {
        self.owner = owner
        self.originalPosition = owner.getPosition().vector3DFromSCNVector3()
        self.targetPosition = owner.getPosition().vector3DFromSCNVector3()
        self.pathfinder = pathfinder
    }
    
    func createPathToPosition(targetPosition:Vector3D) -> [Vector3D] {
        var path:[Vector3D] = [Vector3D]()
        shortestPath = [ShortestPathStep]()

        self.targetPosition = targetPosition
        let ownerPosition = owner.getPosition().vector3DFromSCNVector3()
        shortestPath = pathfinder.findShortestPath(ownerPosition, targetPosition: self.targetPosition)
        
        if(shortestPath.count == 0) {
            print("No path found")
            // REMOVE THIS _ FOR DEBUG ONLY
            //path.append(targetPosition)

        } else {
            for sPath in shortestPath {
                path.append(sPath.position)
            }
            // Add the final target position to the end of the path
            path.append(targetPosition)
        }
        
        return path
    }
    
    func createPathToItem(itemType:Int) -> [Vector3D] {
        let path:[Vector3D] = [Vector3D]()
        
        return path
    }
    
    
}