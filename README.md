## Swift Toast

Toast is a very basic implementation of the Android Toast framework using Swift and auto-layout.

```swift
Toast.makeText("Some message")
Toast.makeText("Another toast", length: .Short)
```

All toasts are added to the keyWindow unless a specific view is passed. The project Toast was developed for required passing the view when creating toast messages in a share extension though it was never needed while in the main application.

```swift
Toast.makeText(self.view, message: "Something happened")
```

All options are configurable and shared across all toast messages so they can easily be set up in the AppDelegate.

```swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    // Toast customizations need to be made before the first toast is called
    Toast.backgroundColor = UIColor(red: 102/255, green: 0/255, blue: 0/255, alpha: 1)
    Toast.textColor = UIColor(red: 255/255, green: 102/255, blue: 0/255, alpha: 1)
    Toast.font = UIFont.boldSystemFontOfSize(18)
    Toast.offset = 20

    Toast.makeText("Hey, it works!")

    return true
}
```

Toasts queue up if multiple are made at a time and will continue displaying until the queue is cleared.

```swift
Toast.makeText("First one")
Toast.makeText("Second one")
Toast.makeText("Third one")
```


### That's it!
Toast was built as a simple alternative to some of the larger libraries that handle complicated views and positioning so the plan is to keep this basic and display strings. I'll try to address any issues that arise, please just help me understand the scenario. Suggestions for enhancements in the form of pull requests are always appreciated.
