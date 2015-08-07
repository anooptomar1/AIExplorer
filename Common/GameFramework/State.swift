//
//  State.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/6/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation

protocol State {
    func enter(obj:GameObject)
    func execute(obj:GameObject)
    func exit(obj:GameObject)
}