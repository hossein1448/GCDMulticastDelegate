# GCDMulticastDelegate

GCDMulticastDelegate is simple class that provides multicast/one-to-many delegation with proper support for GCD queues.
* It provides a means for managing a list of delegates.
* This class also provides proper support for GCD queues.So each delegate specifies which queue they would like their delegate invocations to be dispatched onto.
* All delegate dispatching is done asynchronously. It also uses weak refrences for keep delegates to avoid [Memory Leak](https://en.wikipedia.org/wiki/Memory_leak).
* It's completely thread-safe

For More Information You can refer to [Observer Pattern](https://en.wikipedia.org/wiki/Observer_pattern)

Installation
============
Simply just add `GCDMulticastDelegate.swift` to your project

## Requirements

- iOS 8.0+ / macOS 10.10+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 8.1+
- Swift 3.0+

Usage
============
1. Add to your class: `let gcdMulticastDelegate = GCDMulticastDelegate<MyProtocol>()`
2. implement `addDelegate(deleg delegate:AnyObject, dispatch_queue queue:DispatchQueue)` in your class
3. Other classes must be added as a delegate: `serviceProvide.addDelegate(deleg: self, dispatch_queue: DispatchQueue.main)`
4. When you need to notify your delegates: `multicastDelegate.invoke {$0.someEvent()}`

###Example
```swift
protocol FirstServiceProviderDelegate: class {    
    func onSomeEvent()
}

class FirstServiceProvider: NSObject {
    
    let multicastDelegate:GCDMulticastDelegate = GCDMulticastDelegate<FirstServiceProviderDelegate>()
    
    func testSomeEvent() {
        
        self.multicastDelegate.invoke {
            $0.onSomeEvent()
        }
    }
    
    public func addDelegate(deleg delegate:AnyObject, dispatch_queue queue:DispatchQueue){
        
        multicastDelegate.addDelegate(deleg: delegate as! FirstServiceProviderDelegate, queue: queue)
    }
    
    public func removeDelegate(deleg delegate:AnyObject, dispatch queue:DispatchQueue) {
        
        multicastDelegate.removeDelegate(deleg: delegate, queue: queue)
    }
}
```
```swift
    class ViewController: UIViewController , FirstServiceProviderDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let service = FirstServiceProvider()
        service.addDelegate(deleg: self, dispatch_queue: DispatchQueue.main)
    }
    
    func onSomeEvent() {
        
        print("Some Event Delegate was called")
    }
}
```
use this if You prefer specific GCD queue:
```swift
    let service = FirstServiceProvider()
    let myQueue = DispatchQueue(label: "com.example.my-serial-queue")
    
    service.addDelegate(deleg: self, dispatch_queue: myQueue)
```
also Use `removeDelegate` for removing a class from delegates list

You will find a sample usage of GCDMulticastDelegate in `GCDMulticastDelegateTests.swift`
