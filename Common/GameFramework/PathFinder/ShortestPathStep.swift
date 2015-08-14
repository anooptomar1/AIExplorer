//
//  ShortestPathStep.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/14/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation

class ShortestPathStep : CustomStringConvertible, Equatable {
    var position:Vector3D!
    var gScore:Int!
    var hScore:Int!
    var parent:ShortestPathStep!
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(position:Vector3D) {
        self.position = position
        gScore = 0
        hScore = 0
        parent = nil
    }
    
    func fScore() -> Int {
        return gScore + hScore
    }
    
    var description : String {
        return String("pos = [\(self.position.x), \(self.position.y), \(self.position.z)], g=\(gScore), h=\(hScore), f=\(self.fScore()) ")
    }
    
    func isEqual(other:ShortestPathStep) -> Bool
    {
        return((other.position.x == self.position.x) && (other.position.y == self.position.y) && (other.position.z == self.position.z))
    }
}

func == (lhs: ShortestPathStep, rhs: ShortestPathStep) -> Bool {
    return((lhs.position.x == rhs.position.x) && (lhs.position.y == rhs.position.y) && (lhs.position.z == rhs.position.z))

}