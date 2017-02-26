//
//  GCDMulticastDelegate.swift
//  GCDMulticastDelegate
//
//  Created by Hossein Asgari on 2/24/17.
//  Copyright © 2017 Hossein Asgari. All rights reserved.
//

import UIKit

class GCDMulticastDelegateNode: NSObject {
    
    weak var delegate:AnyObject!
    var delegateQueue:DispatchQueue!
    
    init(delegate del:AnyObject! ,delegateQueue queue:DispatchQueue!) {
        
        delegate = del
        delegateQueue = queue
    }
}



class GCDMulticastDelegate <T>: NSObject {
    
    private var delegateNodes:Array<GCDMulticastDelegateNode> = []
    
    public func addDelegate(deleg delegate:AnyObject! ,queue delegateQueue:DispatchQueue!) {
        
        if delegate == nil {
            return
        }
        
        if delegateQueue == nil {
            return
        }
        
        let node:GCDMulticastDelegateNode = GCDMulticastDelegateNode(delegate: delegate, delegateQueue: delegateQueue);
        
        delegateNodes.append(node)
        
    }
    
    public func removeDelegate(deleg delegate:AnyObject! ,queue delegateQueue:DispatchQueue!) {
        
        if delegate == nil {
            return
        }
        
        for i in (0..<delegateNodes.count).reversed() {
            
            let nodeDelegate:GCDMulticastDelegateNode = delegateNodes[i]
            if nodeDelegate.delegate.isEqual(delegate) {
                
                if delegateQueue == nil || delegateQueue.isEqual(nodeDelegate.delegateQueue) {
                    
                    delegateNodes.remove(at: i)
                }
            }
        }
    }
    
    public func removeDelegate(deleg delegate:AnyObject!) {
        
        if delegate == nil {
            return
        }
        
        for i in (0..<delegateNodes.count).reversed() {
            
            let nodeDelegate:GCDMulticastDelegateNode = delegateNodes[i]
            if nodeDelegate.delegate.isEqual(delegate) {
                
                delegateNodes.remove(at: i)
            }
        }
    }
    
    public func removeAllDelegate() {
        
        delegateNodes.removeAll()
        
    }
    
    public func count() -> Int {
        
        return delegateNodes.count;
    }
    
    public func countOfClass(class cl:AnyClass) -> Int{
        
        var count:Int = 0
        for nodeDelegate in delegateNodes {
            
            if nodeDelegate.delegate.isKind(of: cl) {
                count += 1
            }
        }
        
        return count;
    }
    
    public func countOfSelector(selector sel:Selector) -> Int{
        
        var count:Int = 0
        for nodeDelegate in delegateNodes {
            
            if nodeDelegate.delegate.responds(to: sel) {
                count += 1
            }
        }
        
        return count;
    }
    
    public func invoke(_ invocation: @escaping (T) -> ()) {
        
        
        for i in (0..<delegateNodes.count).reversed() {
            
            let nodeDelegate:GCDMulticastDelegateNode = delegateNodes[i]
            if nodeDelegate.delegate == nil {
                
                delegateNodes.remove(at: i)
                
            }else{
                
                nodeDelegate.delegateQueue.async {
                    
                    invocation(nodeDelegate.delegate as! T)
                }
            }
        }
    }
    
    deinit {
        
        self.delegateNodes.removeAll()
    }
}
