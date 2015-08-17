//
//  Pathfinder.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/16/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation

protocol Pathfinder {
    func findShortestPath(ownerPosition:Vector3D, targetPosition: Vector3D) -> [ShortestPathStep]
}