//
//  PathPlanner.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/14/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import SceneKit

class NavigationMeshPathfinder : Pathfinder {
    let gameUtils = GameUtils()
    var triangles: [MeshTriangle]!
    private var navMeshGraph:NavigationMeshGraph!
    
    var spOpenSteps = [ShortestPathStep]()
    var spClosedSteps = [ShortestPathStep]()
    var shortestPath = [ShortestPathStep]()

    
    init(meshTriangles:[MeshTriangle]) {
        self.triangles = meshTriangles
        self.navMeshGraph = NavigationMeshGraph(v: meshTriangles)
    }
    
        
    func walkableAdjacentTilesCoordForTileCoord(position:Vector3D, targetPosition:Vector3D) -> [Vector3D] {
        var adjSteps:[Vector3D] = [Vector3D]()
        
        let v1 = Vertex(position: position)
        let a = navMeshGraph.nodeGraph.indexOfVertex(v1)
        
        // check if the current step added to the closed steps is one of the vertices of the final position triangle
        let tIndex = self.isVertexInListOfTargetTriangle(position, targetPosition: targetPosition)
        if (tIndex != -1) {
            print("Landed on one of the vertices of the target position enclosing triangle index \(tIndex)")
            adjSteps.append(targetPosition)
            return adjSteps
        }
        
        if(a == nil) {
            print("Could not find vertex in node graph. Trying to find if it is located inside triangles")
            let currentPositionTriangleIndex = self.findTriangleForPosition(position)
            if(currentPositionTriangleIndex != -1) {
                // Handle end position
                adjSteps = self.triangles[currentPositionTriangleIndex].vertices
            }
        } else {
            let vertex = navMeshGraph.nodeGraph.vertexAtIndex(a!)
            let adjVertices = navMeshGraph.nodeGraph.neighborsForVertex(vertex)
            for v in adjVertices! {
                adjSteps.append(v.position)
            }
        }
        
        return adjSteps
    }
    
        
    func findShortestPath(currentPosition:Vector3D, targetPosition:Vector3D) -> [ShortestPathStep] {

        let currentPositionTriangleIndex = self.findTriangleForPosition(currentPosition)
        let targetPositionTriangleIndex = self.findTriangleForPosition(targetPosition)
        
        if(currentPositionTriangleIndex == -1) {
            print("Cannot find triangle index for current Position")
            return shortestPath
        }
        if(targetPositionTriangleIndex == -1) {
            print("Cannot find triangle index for target position")
            return shortestPath
        }
        if(currentPositionTriangleIndex == targetPositionTriangleIndex) {
            print("Target is in same triangle as current position")
            print("Current pos is \(currentPosition) and target is \(targetPosition)")
            
            if(Vector3DEqualToVector3D(currentPosition, targetPosition: targetPosition)) {
                print("Already on target. Reversing direction...")
                return shortestPath
            } else {
                return shortestPath
            }
        }

        // Start by adding the from position to the open list
        self.insertInOpenSteps(ShortestPathStep(position: currentPosition))
        
        var currentStep:ShortestPathStep!
        
        repeat {
            // Get the lowest F cost step
            // Because the list is ordered, the first step is always the one with the lowest F cost
            currentStep = spOpenSteps[0]
        
            print("CURRENT STEP: \(currentStep.position)")
            print("TARGET POSITION: \(targetPosition)")
        
            // Add the current step to the closed set
            spClosedSteps.append(currentStep)
        
            // Remove it from the open list
            spOpenSteps.removeAtIndex(0)
        
            if (Vector3DEqualToVector3D(currentStep.position, targetPosition:targetPosition)) {
                self.constructPath(currentStep)
                break
            }
        
            // Get the adjacent tiles coord of the current step
            let adjSteps = self.walkableAdjacentTilesCoordForTileCoord(currentStep.position, targetPosition:targetPosition)

            for v in adjSteps {
                //print("Adjacent step is \(v) for position:\(currentStep.position)")
        
                var step = ShortestPathStep(position: v)
        
                // Check if the step isn't already in the closed set
                if (spClosedSteps.contains(step)) {
                    continue; // Ignore it
                }
        
                // Compute the cost from the current step to that step
                let moveCost = self.costToMoveFromStep(currentStep, toAdjacentStep:step)
        
                // Check if the step is already in the open list
                let index:Int? = spOpenSteps.indexOf(step)
        
                if (index == nil) { // Not on the open list, so add it
        
                    // Set the current step as the parent
                    step.parent = currentStep;
        
                    // The G score is equal to the parent G score + the cost to move from the parent to it
                    step.gScore = currentStep.gScore + moveCost;
        
                    // Compute the H score which is the estimated movement cost to move from that step to the desired tile coordinate
                    step.hScore = self.computeHScoreFromCoord(step.position, toCoord:targetPosition)
        
                    // Adding it with the function which is preserving the list ordered by F score
                    self.insertInOpenSteps(step)
        
                } else { // Already in the open list
                    let foundIndex = index
                    step = spOpenSteps[foundIndex!] // To retrieve the old one (which has its scores already computed ;-)
        
                    // Check to see if the G score for that step is lower if we use the current step to get there
                    if ((currentStep.gScore + moveCost) < step.gScore) {
        
                        // The G score is equal to the parent G score + the cost to move from the parent to it
                        step.gScore = currentStep.gScore + moveCost;
                        // Because the G Score has changed, the F score may have changed too
                        // So to keep the open list ordered we have to remove the step, and re-insert it with
                        // the insert function which is preserving the list ordered by F score
            
                        // Now we can removing it from the list without be afraid that it can be released
                        spOpenSteps.removeAtIndex(foundIndex!)
            
                        // Re-insert it with the function which is preserving the list ordered by F score
                        self.insertInOpenSteps(step)
            
                    }
                }
            }
            
        } while(spOpenSteps.count > 0)
        
        return shortestPath
    }
    
    
    func constructPath(var step:ShortestPathStep?) {
        let nilStep:ShortestPathStep? = nil
        repeat {
            if (step!.parent != nil) { // Don't add the last step which is the start position (remember we go backward, so the last one is the origin position ;-)
                shortestPath.insert(step!, atIndex:0) // Always insert at index 0 to reverse the path
            }
            step = step!.parent // Go backward
        } while (step != nilStep) // Until there is no more parents
        
        
        for s in shortestPath {
            print("SHORTEST PATH is \(s)")
        }
        
    }
    
    func insertInOpenSteps(step:ShortestPathStep) {
        let stepFScore = step.fScore()
        let count = spOpenSteps.count
        
        var i:Int = 0 // This will be the index at which we will insert the step
        for (; i < count; i++) {
            if (stepFScore <= spOpenSteps[i].fScore()) { // If the step's F score is lower or equals to the step at index i
                // Then we found the index at which we have to insert the new step
                // Basically we want the list sorted by F score
                break
            }
        }
        // Insert the new step at the determined index to preserve the F score ordering
        spOpenSteps.insert(step, atIndex:i)
    }
    
    // Compute the H score from a position to another (from the current position to the final desired position
    func computeHScoreFromCoord(fromCoord:Vector3D, toCoord:Vector3D) -> Int
    {
        // Here we use the Manhattan method, which calculates the total number of step moved horizontally and vertically to reach the
        // final desired step from the current step, ignoring any obstacles that may be in the way
        return Int(abs(toCoord.x - fromCoord.x) + abs(toCoord.z - fromCoord.z))
    }

    // Compute the cost of moving from a step to an adjacent one
    func costToMoveFromStep(fromStep:ShortestPathStep, toAdjacentStep:ShortestPathStep) -> Int
    {
        // Because we can't move diagonally and because terrain is just walkable or unwalkable the cost is always the same.
        // But it have to be different if we can move diagonally and/or if there is swamps, hills, etc...
        return Int(abs(fromStep.position.x - toAdjacentStep.position.x) + abs(fromStep.position.z - toAdjacentStep.position.z))
    }

    func isVertexInListOfTargetTriangle(position:Vector3D, targetPosition:Vector3D) -> Int {
        let triIndex = self.findTriangleForPosition(targetPosition)
        if(triIndex != -1) {
            if(self.triangles[triIndex].hasVertex(position) == true) {
                return triIndex
            }
        }
        return -1
        
    }
    
    func printTriangleInfo() {
        var idx = 0
        for triangle in self.triangles {
            print("Triangle[\(idx)]:vertices:\(triangle.vertices[0]), \(triangle.vertices[1]), \(triangle.vertices[2])")
            idx++
        }
    }
    
    func findTriangleForPosition(position:Vector3D) -> Int {
        var idx = 0
        for triangle in self.triangles {
            let inTriangle = gameUtils.accuratePointInTriangle(triangle.vertices[0], v2: triangle.vertices[1], v3: triangle.vertices[2], v: position)
            if(inTriangle == true) {
                print("Found pt in triangle index \(idx), vertices:\(triangle.vertices[0]), \(triangle.vertices[1]), \(triangle.vertices[2])")
                return idx
            }
            idx++
        }
        return -1
    }

    
}