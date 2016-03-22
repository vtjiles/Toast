//
//  Toast.swift
//  noosh
//
//  Created by Jason Iles on 3/14/16.
//  Copyright © 2016 Jiles, LLC. All rights reserved.
//

import UIKit

enum ToastLength: Double {
    case Long = 3.5
    case Short = 2
}

class Toast {    
    // visible views can be reused
    private static var container: UIView?
    private static var label: UILabel?
    
    // keep track of requested toasts
    private static var queue = [(UIView, String, ToastLength)]()
    
    // whether or not we're currently displaying a toast
    private static var running = false
    
    // globally configurable options
    static var backgroundColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
    static var textColor = UIColor.whiteColor()
    static var font = UIFont.systemFontOfSize(18)
    static var numberOfLines = 0
    static var cornerRadius = 18
    static var verticalPadding = 8
    static var horizontalPadding = 18
    static var fadeDuration = 0.5
    static var offset = 70
    static var horizontalMargin = 20
    
    // create our toast container and label
    private static func getToastViews() -> (UIView, UILabel) {
        // create label
        if label == nil {
            label = UILabel()
            label!.sizeToFit()
            label!.textAlignment = .Center
            label!.lineBreakMode = .ByWordWrapping
            label!.numberOfLines = numberOfLines
            label!.textColor = textColor
            label!.font = font
        }
        
        // create container
        if container == nil {
            container = UIView()
            container!.backgroundColor = backgroundColor
            container!.layer.cornerRadius = CGFloat(cornerRadius)
            container!.layer.zPosition = 1
            container!.clipsToBounds = true
            container!.addSubview(label!)
        }
        
        return (container!, label!)
    }
    
    // methods without controller passed
    static func makeText(message: String) {
        self.makeText(message, length: .Long)
    }
    
    static func makeText(message: String, length: ToastLength) {
        // try to get key window
        var target: UIWindow? = UIApplication.sharedApplication().keyWindow
        
        // otherwise try to use app delegate to get it
        if target == nil {
            target = UIApplication.sharedApplication().delegate?.window ?? nil
        }
        
        // if we have a window, get the controller
        if let window = target {
            self.makeText(window, message: message, length: length)
        }
    }
    
    // methods when controller is passed
    static func makeText(view: UIView, message: String) {
        self.makeText(view, message: message, length: .Long)
    }
    
    static func makeText(view: UIView, message: String, length: ToastLength) {
        // queue this request
        queue.append((view, message, length))
        
        // run the toast if it's not already running
        makeNextToast()
    }
    
    // loop through and generate any outstanding toasts
    private static func makeNextToast() {
        // don't run if we don't need to
        if queue.isEmpty || running {
            return
        }
        
        // make sure we're running
        running = true
        
        // get the first item in the queue
        let config = queue.first!
        
        // define variables fromt he config
        let view = config.0
        let message = config.1
        let length = config.2
        
        // make sure that element is gone from the queue
        queue.removeFirst()
        
        // get our view.
        let (container, label) = getToastViews()
        
        // set our message
        label.text = message
        
        // hide it
        container.alpha = 0
        
        // add to our main view
        view.addSubview(container)
        container.window?.bringSubviewToFront(container)
        
        // used for a slight animation
        var bottomConstraint: NSLayoutConstraint?
        
        // reset any existing constraints
        container.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // add to bottom of the screen
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: container, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: container, attribute: .Left, relatedBy: .GreaterThanOrEqual, toItem: view, attribute: .Left, multiplier: 1, constant: CGFloat(Toast.horizontalMargin)))
        constraints.append(NSLayoutConstraint(item: container, attribute: .Right, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Right, multiplier: 1, constant: CGFloat(-1 * Toast.horizontalMargin)))
        bottomConstraint = NSLayoutConstraint(item: container, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
        constraints.append(bottomConstraint!)
        
        // make sure the label has some padding
        constraints.append(NSLayoutConstraint(item: label, attribute: .Left, relatedBy: .Equal, toItem: container, attribute: .Left, multiplier: 1, constant: CGFloat(Toast.horizontalPadding)))
        constraints.append(NSLayoutConstraint(item: label, attribute: .Right, relatedBy: .Equal, toItem: container, attribute: .Right, multiplier: 1, constant: CGFloat(-1 * Toast.horizontalPadding)))
        constraints.append(NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: container, attribute: .Top, multiplier: 1, constant: CGFloat(Toast.verticalPadding)))
        constraints.append(NSLayoutConstraint(item: label, attribute: .Bottom, relatedBy: .Equal, toItem: container, attribute: .Bottom, multiplier: 1, constant: CGFloat(-1 * Toast.verticalPadding)))
        
        // set our constraints
        NSLayoutConstraint.activateConstraints(constraints)
        
        // define our bottom offset
        let beginOffset = -0.9 * CGFloat(Toast.offset)
        bottomConstraint?.constant = beginOffset
        
        // make sure view is positioned
        container.layoutIfNeeded()
        
        // update bottom offset
        bottomConstraint?.constant = -1 * CGFloat(Toast.offset)
        UIView.animateWithDuration(Toast.fadeDuration, animations: { () -> Void in
            // animate fade in and change to bottom offset
            container.alpha = 1
            view.layoutIfNeeded()
            }, completion: { (finished: Bool) -> Void in
                // set bottom offset back to original
                bottomConstraint?.constant = beginOffset
                
                // determine how long we want to delay so the whole thing takes the expected time.
                // ensure it's visible for at least 1 second
                let delay = max(length.rawValue - 2 * Toast.fadeDuration, 1.0)
                
                // wait, then animate
                UIView.animateWithDuration(Toast.fadeDuration, delay: delay, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
                    // animate fade out and bottom offset
                    container.alpha = 0
                    container.layoutIfNeeded()
                    }, completion: { (Bool) -> Void in
                        // remove from view
                        container.removeFromSuperview()
                        
                        // make sure we're no longer running so a new toast can run
                        self.running = false
                        
                        // run any remaining toasts
                        self.makeNextToast()
                })
        })
    }
}
