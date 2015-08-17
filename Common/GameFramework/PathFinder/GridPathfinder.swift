//
//  GridPathfinder.swift
//  3DGameTutorial
//
//  Created by Vivek Nagar on 8/17/14.
//  Copyright (c) 2014 Vivek Nagar. All rights reserved.
//

import GameplayKit
import SceneKit

struct GridSquare {
    var x:Int!
    var y:Int!
    var valid:Bool!
}

class GridGraph {
    var left:CGFloat!
    var right:CGFloat!
    var bottom:CGFloat!
    var top:CGFloat!
    var columns:Int!
    var rows:Int!
    var grids:[GridSquare]!
    
    var grid2d: [[Int]] = [
                            [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
                            [0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0],
                            [0,1,1,1,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0],
                            [0,1,1,1,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0],
                            [0,1,1,1,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0],
                            [0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0],
                            [0,1,1,1,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0],
                            [0,1,1,1,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0],
                            [0,1,1,1,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0],
                            [0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0],
                            [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
                        ]
    
    init(left:CGFloat, bottom:CGFloat, right:CGFloat, top:CGFloat) {
        self.left = left
        self.right = right
        self.top = top
        self.bottom = bottom
        
        let width = right - left
        let height = top - bottom
        rows = Int(width / 50.0)
        columns = Int(height/50.0)
        
        //print("rows = \(rows), columns = \(columns)")
        grids = [GridSquare]()
        var grid:GridSquare!
        var idx:Int = 0
        var v:Bool!
        for row in 0...rows {
            for column in 0...columns {
                //print("GRID 2D value for row \(row) and column \(column) is \(grid2d[row][column])")
                //if((row == 6 || row == 7 || row == 8 || row == 9) && (column == 8 || column == 9)) {
                if(grid2d[row][column] == 0) {
                    v = false
                } else {
                    v = true
                }
                grid = GridSquare(x:row, y:column, valid:v)

                grids.append(grid)
                //print("tile x: \(row) , y: \(column), idx is \(idx)")

                idx++
            }
        }
        
    }
    
    func isValidTileCoord(tileCoord:Vector3D) -> Bool {
        var isValid = true
        
        let idx = Int(tileCoord.x)*(columns+1) + Int(tileCoord.y)
        //print("TILE coord x: \(tileCoord.x) , y: \(tileCoord.y), idx is \(idx)")
        
        isValid = grids[idx].valid
        return isValid;
    }
    
    func getTileCoord(location:Vector3D) -> Vector3D {
        let locX = round(location.x) - Float(self.left)
        let locZ = round(location.z) - Float(self.bottom)
        let tileX:Int = Int(locX/50.0)
        let tileZ:Int = Int(locZ/50.0)
        
        return Vector3D(x:Float(tileX), y:0.0, z:Float(tileZ))
    }
    
    func getLocationFromTileCoord(tileCoord:Vector3D) -> Vector3D {
        let x = Float(tileCoord.x * 50.0) + Float(left)
        let z = Float(tileCoord.y * 50.0) + Float(bottom)
        
        return Vector3D(x:x, y:0.0, z:z)
    }

    func getGrids() -> [GridSquare] {
        return grids
    }
}



class GridPathfinder {
    var reverse:Bool = false
    var gridGraph:GridGraph!
    var spOpenSteps:[ShortestPathStep] = [ShortestPathStep]()
    var spClosedSteps:[ShortestPathStep] = [ShortestPathStep]()
    var target:Vector3D!
    var original:Vector3D!
    var targetPosition:Vector3D!
    var shortestPath:[ShortestPathStep]! = [ShortestPathStep]()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        self.original = Vector3D(x: 0.0, y:0.0, z: 0.0)
        self.target = Vector3D(x: 200.0, y: 0.0, z: 250.0)
        self.targetPosition = self.target
        self.gridGraph = GridGraph(left:-250, bottom: -400, right: 250, top: 600)
    }
    
    func getGrids() -> [GridSquare] {
        return gridGraph.getGrids()
        
    }

    func getNextNode(currentPosition:Vector3D) -> Vector3D {
        let nextNodePosition:Vector3D = targetPosition
        
        let fromTileCoord = gridGraph.getTileCoord(currentPosition)
        let toTileCoord = gridGraph.getTileCoord(targetPosition)
        
        if(Vector3DEqualToVector3D(fromTileCoord, targetPosition: toTileCoord)) {
            print("Already on tile. Reversing direction...")
            spOpenSteps = [ShortestPathStep]()
            spClosedSteps = [ShortestPathStep]()
            shortestPath = [ShortestPathStep]()

            if(reverse == false) {
                targetPosition = original
                reverse = true
            } else {
                reverse = false
                targetPosition = self.target

            }
            //return nextNodePosition
            return targetPosition
        }
        
        if(shortestPath.count > 0) {
            let s = shortestPath[0]
            //print("element from shortest path \(s.position.x) and \(s.position.y), tilecoord \(fromTileCoord.x) and \(fromTileCoord.y)")

            if(Vector3DEqualToVector3D(fromTileCoord, targetPosition:s.position)) {
                //print("Removing element from shortest path \(s.position.x) and \(s.position.y)")
                shortestPath.removeAtIndex(0)
            }
            return gridGraph.getLocationFromTileCoord(s.position)
        }
        //check if the tile is walkable (check for walls etc)
        
        //var pathFound = false
        
        // Start by adding the from position to the open list
        self.insertInOpenSteps(ShortestPathStep(position: fromTileCoord))
        
        repeat {
            // Get the lowest F cost step
            // Because the list is ordered, the first step is always the one with the lowest F cost
            let currentStep = self.spOpenSteps[0]
            
            // Add the current step to the closed set
            self.spClosedSteps.append(currentStep)
            
            // Remove it from the open list
            // Note that if we wanted to first removing from the open list, care should be taken to the memory
            self.spOpenSteps.removeAtIndex(0)
            
            // If the currentStep is the desired tile coordinate, we are done!
            if (Vector3DEqualToVector3D(currentStep.position, targetPosition:toTileCoord)) {
                
                self.constructPath(currentStep)
                break
            }
            
            // Get the adjacent tiles coord of the current step
            let adjSteps = self.walkableAdjacentTilesCoordForTileCoord(currentStep.position)
            for v in adjSteps {
                var step = ShortestPathStep(position: v)
                
                // Check if the step isn't already in the closed set
                if (self.spClosedSteps.contains(step)) {
                    continue; // Ignore it
                }
                
                // Compute the cost from the current step to that step
                let moveCost = self.costToMoveFromStep(currentStep, toAdjacentStep:step)
                
                // Check if the step is already in the open list
                let index:Int? = self.spOpenSteps.indexOf(step)
                
                if (index == nil) { // Not on the open list, so add it
                    
                    // Set the current step as the parent
                    step.parent = currentStep;
                    
                    // The G score is equal to the parent G score + the cost to move from the parent to it
                    step.gScore = currentStep.gScore + moveCost;
                    
                    // Compute the H score which is the estimated movement cost to move from that step to the desired tile coordinate
                    step.hScore = self.computeHScoreFromCoord(step.position, toCoord:toTileCoord)
                    
                    // Adding it with the function which is preserving the list ordered by F score
                    self.insertInOpenSteps(step)
                    
                }
                else { // Already in the open list
                    let foundIndex = index
                    step = self.spOpenSteps[foundIndex!] // To retrieve the old one (which has its scores already computed ;-)
                    
                    // Check to see if the G score for that step is lower if we use the current step to get there
                    if ((currentStep.gScore + moveCost) < step.gScore) {
                        
                        // The G score is equal to the parent G score + the cost to move from the parent to it
                        step.gScore = currentStep.gScore + moveCost;
                        
                        // Because the G Score has changed, the F score may have changed too
                        // So to keep the open list ordered we have to remove the step, and re-insert it with
                        // the insert function which is preserving the list ordered by F score
                        
                        // Now we can removing it from the list without be afraid that it can be released
                        self.spOpenSteps.removeAtIndex(foundIndex!)
                        
                        // Re-insert it with the function which is preserving the list ordered by F score
                        self.insertInOpenSteps(step)
                        
                    }
                }
            }
            
        } while( self.spOpenSteps.count > 0)
        
        if(self.shortestPath.count == 0) {
            print("No path found")
        }
        
        return nextNodePosition
    }
    
    func constructPath(var step:ShortestPathStep?) {
        let nilStep:ShortestPathStep? = nil
        repeat {
            if (step!.parent != nil) { // Don't add the last step which is the start position (remember we go backward, so the last one is the origin position ;-)
                self.shortestPath.insert(step!, atIndex:0) // Always insert at index 0 to reverse the path
            }
            step = step!.parent // Go backward
        } while (step != nilStep) // Until there is no more parents
        
        /*
        for s in self.shortestPath {
            print("path \(s)")
        }
        */
    }
    
    func insertInOpenSteps(step:ShortestPathStep) {
        let stepFScore = step.fScore()
        let count = spOpenSteps.count
        
        var i:Int = 0 // This will be the index at which we will insert the step
        for (; i < count; i++) {
            if (stepFScore <= self.spOpenSteps[i].fScore()) { // If the step's F score is lower or equals to the step at index i
                // Then we found the index at which we have to insert the new step
                // Basically we want the list sorted by F score
                break
            }
        }
        // Insert the new step at the determined index to preserve the F score ordering
        self.spOpenSteps.insert(step, atIndex:i)
    }
    
    // Compute the H score from a position to another (from the current position to the final desired position
    func computeHScoreFromCoord(fromCoord:Vector3D, toCoord:Vector3D) -> Int
    {
        // Here we use the Manhattan method, which calculates the total number of step moved horizontally and vertically to reach the
        // final desired step from the current step, ignoring any obstacles that may be in the way
        return Int(abs(toCoord.x - fromCoord.x) + abs(toCoord.y - fromCoord.y))
    }
    
    // Compute the cost of moving from a step to an adjacent one
    func costToMoveFromStep(fromStep:ShortestPathStep, toAdjacentStep:ShortestPathStep) -> Int
    {
        // Because we can't move diagonally and because terrain is just walkable or unwalkable the cost is always the same.
        // But it have to be different if we can move diagonally and/or if there is swamps, hills, etc...
        return 1;
    }
    
    func walkableAdjacentTilesCoordForTileCoord(tileCoord:Vector3D) -> [Vector3D] {
        var tmp = [Vector3D]()
        var p = Vector3D(x:tileCoord.x, y:0.0, z:tileCoord.y - 1)
        
        if (gridGraph.isValidTileCoord(p)) {
            tmp.append(p)
        }
        
        // Left
        p = Vector3D(x:tileCoord.x - 1, y:0.0, z:tileCoord.y)
        if (gridGraph.isValidTileCoord(p)) {
            tmp.append(p)
        }
        
        // Bottom
        p = Vector3D(x:tileCoord.x, y:0.0, z:tileCoord.y + 1)
        if (gridGraph.isValidTileCoord(p)) {
            tmp.append(p)
        }
        
        // Right
        p = Vector3D(x:tileCoord.x + 1, y:0.0, z:tileCoord.y)
        if (gridGraph.isValidTileCoord(p)) {
            tmp.append(p)
        }
        
        return tmp
    }
    
    func getLocationFromTileCoord(tileCoord:Vector3D) -> Vector3D {
        return gridGraph.getLocationFromTileCoord(tileCoord)
    }

    
}
