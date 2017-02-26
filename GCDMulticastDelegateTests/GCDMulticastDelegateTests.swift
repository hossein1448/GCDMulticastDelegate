//
//  GCDMulticastDelegateTests.swift
//  GCDMulticastDelegateTests
//
//  Created by Hossein Asgari on 2/24/17.
//  Copyright © 2017 Hossein Asgari. All rights reserved.
//

import XCTest

protocol FirstServiceProviderDelegate: class {
    
    func onSomeEvent()
    func onSomeEventWithValue(value:Int)
    
}

class FirstServiceProvider: NSObject {
    
    let multicastDelegate:GCDMulticastDelegate = GCDMulticastDelegate<FirstServiceProviderDelegate>()
    
    func testSomeEvent() {
        
        self.multicastDelegate.invoke {
            $0.onSomeEvent()
        }
    }
    
    func testSomeEventWithValue() {
        
        self.multicastDelegate.invoke {
            $0.onSomeEventWithValue(value: 1448)
        }
    }
    
    public func addDelegate(deleg delegate:AnyObject, dispatch_queue queue:DispatchQueue){
        
        multicastDelegate.addDelegate(deleg: delegate as! FirstServiceProviderDelegate, queue: queue)
    }
    
    public func removeDelegate(deleg delegate:AnyObject, dispatch queue:DispatchQueue) {
        
        multicastDelegate.removeDelegate(deleg: delegate, queue: queue)
    }
}

protocol SecondServiceProviderDelegate: class {
    
    func onSomeEventGCD()
}

class SecondServiceProvider: NSObject {
    
    let multicastDelegate:GCDMulticastDelegate = GCDMulticastDelegate<SecondServiceProviderDelegate>()
    
    func testSomeEventGCD() {
        
        self.multicastDelegate.invoke {
            $0.onSomeEventGCD()
        }
    }
    
    public func addDelegate(deleg delegate:AnyObject, dispatch_queue queue:DispatchQueue){
        
        multicastDelegate.addDelegate(deleg: delegate as! SecondServiceProviderDelegate, queue: queue)
    }
    
    public func removeDelegate(deleg delegate:AnyObject, dispatch queue:DispatchQueue) {
        
        multicastDelegate.removeDelegate(deleg: delegate, queue: queue)
    }
}


@testable import GCDMulticastDelegate

class GCDMulticastDelegateTests: XCTestCase , FirstServiceProviderDelegate , SecondServiceProviderDelegate{
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDelegateUsage() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let serviceProvide:FirstServiceProvider = FirstServiceProvider()
        serviceProvide.addDelegate(deleg: self, dispatch_queue: DispatchQueue.main)
        
        serviceProvide.testSomeEvent()
        serviceProvide.testSomeEventWithValue()
        
        let exp = self.expectation(description: "wait for finish unSyncCall")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) { 
            
            exp.fulfill()
        }
        
        self.waitForExpectations(timeout: 40, handler: nil)
        
    }
    
    func testDelegateGCDUsage() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let serviceProvide:SecondServiceProvider = SecondServiceProvider()
        let testQueue = DispatchQueue(label: "com.test.gcd-multicast-delegae-queue")
        serviceProvide.addDelegate(deleg: self, dispatch_queue: testQueue)
        
        serviceProvide.testSomeEventGCD()
        
        let exp = self.expectation(description: "wait for finish unSyncCall in GCD")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            
            exp.fulfill()
        }
        
        self.waitForExpectations(timeout: 40, handler: nil)
        
    }
    
    func currentQueueName() -> String? {
        let name = __dispatch_queue_get_label(nil)
        return String(cString: name, encoding: .utf8)
    }
    
    // MARK: FirstServiceProviderDelegate
    func onSomeEvent(){
    
        XCTAssertTrue(Thread.isMainThread)
        
    }
    func onSomeEventWithValue(value:Int){
    
        XCTAssertEqual(value, 1448)
        XCTAssertTrue(Thread.isMainThread)
    }
    
    // MARK: SecondServiceProviderDelegate
    func onSomeEventGCD() {
        
        XCTAssertFalse(Thread.isMainThread)
        XCTAssertEqual(self.currentQueueName(), "com.test.gcd-multicast-delegae-queue")
    }
}
