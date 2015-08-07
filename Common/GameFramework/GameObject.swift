//
//  GameObject.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/15/14.
//  Copyright (c) 2014 Vivek Nagar. All rights reserved.
//

import SceneKit

protocol GameObject  {
    func getID() -> String
    func update(deltaTime:NSTimeInterval)
    func isStatic() -> Bool

}

