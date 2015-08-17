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



