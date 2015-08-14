//
//  Path.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/11/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation


class Path {
    var wayPoints = [Vector3D]()
    var currentWayPoint:Vector3D!
        
    var currentWayPointIndex = 0
    var looped = false
    
    init(looped:Bool, waypoints:[Vector3D]) {
        self.looped = looped
        self.wayPoints = waypoints
        if(self.wayPoints.count > 0) {
            currentWayPoint = self.wayPoints[0]
        }
    }
    
    func addWayPoint(waypoint:Vector3D) {
        wayPoints.append(waypoint)
    }
    
    func getCurrentWayPoint() -> Vector3D {
        return self.currentWayPoint
    }
    
    func setNextWayPoint() {
        self.currentWayPoint = self.wayPoints[currentWayPointIndex]

        currentWayPointIndex++
        if(currentWayPointIndex == self.wayPoints.count) {
            if(looped) {
                currentWayPointIndex = 0
            } else {
                print("Reached end of path")
            }
        }
    }
    
    func finished() -> Bool {
        if((currentWayPointIndex == self.wayPoints.count - 1) && (looped == false)) {
            return true
        }
        return false
    }
}