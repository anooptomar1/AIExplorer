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
    var left:Float!
    var right:Float!
    var bottom:Float!
    var top:Float!
    var columns:Int = 0
    var rows:Int = 0
    var grids:[GridSquare]!
    var widthStep:Int = 0
    var heightStep:Int = 0
    
    var grid2d:[[Int]]!
    init(left:Float, bottom:Float, right:Float, top:Float, grid2d:[[Int]]) {
        self.left = left
        self.right = right
        self.top = top
        self.bottom = bottom
        self.grid2d = grid2d
        
        for first in grid2d {
            columns = 0
            for _ in first {
                columns++
            }
            rows++
        }
        rows = rows - 1
        columns = columns - 1
        print("rows = \(rows), columns = \(columns)")

        
        let width = right - left
        let height = top - bottom
        widthStep = Int(width) / rows
        heightStep = Int(height) / rows
        
        grids = [GridSquare]()
        var grid:GridSquare!
        var idx:Int = 0
        var v:Bool!
        for row in 0...rows {
            for column in 0...columns {
                //print("GRID 2D value for row \(row) and column \(column) is \(grid2d[row][column])")
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
        
        let idx = Int(tileCoord.x)*(columns+1) + Int(tileCoord.z)
        //print("TILE coord x: \(tileCoord.x) , z: \(tileCoord.y), idx is \(idx)")
        
        isValid = grids[idx].valid
        return isValid;
    }
    
    func getTileCoord(location:Vector3D) -> Vector3D {
        let locX = round(location.x) - Float(self.left)
        let locZ = round(location.z) - Float(self.bottom)
        let tileX:Int = Int(locX)/widthStep
        let tileZ:Int = Int(locZ)/widthStep
        
        return Vector3D(x:Float(tileX), y:0.0, z:Float(tileZ))
    }
    
    func getLocationFromTileCoord(tileCoord:Vector3D) -> Vector3D {
        let x = Float(tileCoord.x) * Float(widthStep) + Float(left)
        let z = Float(tileCoord.z) * Float(widthStep) + Float(bottom)
        
        return Vector3D(x:x, y:0.0, z:z)
    }

    func getGrids() -> [GridSquare] {
        return grids
    }
}



