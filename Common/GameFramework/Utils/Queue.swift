//
//  Queue.swift
//  AIExplorer
//
//  Created by Vivek Nagar on 8/13/15.
//  Copyright © 2015 Vivek Nagar. All rights reserved.
//

import Foundation

class QNode<T> {
    var key: T?
    var next: QNode?
}

public class Queue<T> {
    private var top: QNode<T>! = QNode<T>() //enqueue the specified object 
    func enQueue( key: T) {
        //check for the instance 
        if (top == nil) {
            top = QNode<T>()
        }
        //establish the top node 
        if (top.key == nil) {
            top.key = key;
            return
        }
        
        let childToUse: QNode<T> = QNode<T>()
        var current: QNode = top
        //cycle through the list of items to get to the end. 
        while (current.next != nil) {
            current = current.next!
        }
        //append a new item 
        childToUse.key = key;
        current.next = childToUse;
        
    }
    
    //retrieve items from the top level in O(1) constant time 
    func deQueue() -> T? {
        //determine if the key or instance exists 
        let topitem: T? = self.top?.key
        
        if (topitem == nil) {
            return nil
        }
        //retrieve and queue the next item 
        let queueitem: T? = top.key!
        //use optional binding 
        if let nextitem = top.next {
            top = nextitem
        } else {
            top = nil
        }
        return queueitem
    }
    
    //check for the presence of a value 
    func isEmpty() -> Bool {
        //determine if the key or instance exist 
        if let _: T = self.top?.key {
            return false
        } else {
            return true
        }
    }
    
    //retrieve the top most item 
    func peek() -> T? {
        return top.key!
    }
    
    func size() -> Int {
        var count = 0
        var current: QNode = top
        //cycle through the list of items to get to the end. 
        while (current.next != nil) {
            count++
            current = current.next!
        }
        return count
    }
}