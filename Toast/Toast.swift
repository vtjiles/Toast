//
//  AppDelegate.swift
//  Toast
//
//  Created by Jason Iles on 3/22/16.
//  Copyright © 2016 jiles. All rights reserved.
//

import UIKit

class Toast {
    enum ToastLength: Double {
        case Long = 3.5
        case Short = 2
    }
    
    // keep track of requested toasts
    private static var queue = [(UIView?, String, ToastLength)]()
    
    // whether or not we're currently displaying a toast
    private static var running = false
    
    // globally configurable options
    static var backgroundColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
    static var textColor = UIColor.whiteColor()
    static var font = UIFont.systemFontOfSize(16)
    static var numberOfLines = 0
    static var cornerRadius = 17
    static var verticalPadding = 8
    static var horizontalPadding = 18
    static var fadeDuration = 0.5
    static var offset: CGFloat = 70
    static var horizontalMargin = 20
    
    // methods without view passed
    static func makeText(message: String) {
        self.makeText(message, length: .Long)
    }
    
    static func makeText(message: String, length: ToastLength) {
        self.makeText(nil, message: message, length: length)
        
    }
    
    // methods with view passed
    static func makeText(view: UIView?, message: String) {
        self.makeText(view, message: message, length: .Long)
    }
    
    static func makeText(view: UIView?, message: String, length: ToastLength) {
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
        
        // make sure that element is gone from the queue
        queue.removeFirst()
        
        // define variables from the config
        let view = config.0
        let message = config.1
        let length = config.2
        
        let toast = ToastView(view: view)
        
        toast.show(message, length: length, completion: {
            // make sure we're no longer running so a new toast can run
            self.running = false
            
            // run any remaining toasts
            self.makeNextToast()
        })
    }
    
    private class ToastView: UIView {
        // create our label
        private let label = UILabel()
        
        // passed view
        private var requestedView: UIView?
        
        // hold constraints
        private var toastConstraints = [NSLayoutConstraint]()
        
        // used for a slight animation
        var bottomConstraint: NSLayoutConstraint?
        
        init(view: UIView?) {
            super.init(frame: CGRectZero)
            self.requestedView = view
            createLayout()
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            createLayout()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            createLayout()
        }
        
        private func createLayout() {
            // style background
            self.alpha = 0
            self.backgroundColor = Toast.backgroundColor
            self.layer.cornerRadius = CGFloat(Toast.cornerRadius)
            self.layer.zPosition = 1
            self.clipsToBounds = true
            
            // style label
            label.sizeToFit()
            label.textAlignment = .Center
            label.lineBreakMode = .ByWordWrapping
            label.numberOfLines = Toast.numberOfLines
            label.textColor = Toast.textColor
            label.font = Toast.font
            
            // try to get front window
            let app = UIApplication.sharedApplication()
            
            // try to use a passed view
            var target: UIView? = requestedView ?? app.keyWindow
            
            // otherwise try to use app delegate to get it
            if target == nil {
                target = app.delegate?.window ?? nil
            }
            
            // should always have a view
            if let view = target {
                // add views
                self.addSubview(label)
                view.addSubview(self)
                
                // reset any existing constraints
                self.translatesAutoresizingMaskIntoConstraints = false
                label.translatesAutoresizingMaskIntoConstraints = false
                
                // add to bottom of the screen
                toastConstraints.append(NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
                toastConstraints.append(NSLayoutConstraint(item: self, attribute: .Left, relatedBy: .GreaterThanOrEqual, toItem: view, attribute: .Left, multiplier: 1, constant: CGFloat(Toast.horizontalMargin)))
                toastConstraints.append(NSLayoutConstraint(item: self, attribute: .Right, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Right, multiplier: 1, constant: CGFloat(-1 * Toast.horizontalMargin)))
                bottomConstraint = NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
                toastConstraints.append(bottomConstraint!)
                
                // make sure the label has some padding
                toastConstraints.append(NSLayoutConstraint(item: label, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: CGFloat(Toast.horizontalPadding)))
                toastConstraints.append(NSLayoutConstraint(item: label, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: CGFloat(-1 * Toast.horizontalPadding)))
                toastConstraints.append(NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: CGFloat(Toast.verticalPadding)))
                toastConstraints.append(NSLayoutConstraint(item: label, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: CGFloat(-1 * Toast.verticalPadding)))
            }
        }
        
        func show(message: String, length: Toast.ToastLength, completion: () -> ()) {
            label.text = message
            
            self.window?.bringSubviewToFront(self)
            
            // set our constraints
            NSLayoutConstraint.activateConstraints(toastConstraints)
            
            // define our bottom offset
            let beginOffset = -0.9 * CGFloat(Toast.offset)
            bottomConstraint?.constant = beginOffset
            
            // make sure view is positioned
            self.layoutIfNeeded()
            
            // update bottom offset
            bottomConstraint?.constant = -1 * CGFloat(offset)
            UIView.animateWithDuration(Toast.fadeDuration, animations: { () -> Void in
                // animate fade in and change to bottom offset
                self.alpha = 1
                self.superview?.layoutIfNeeded()
                
                }, completion: { (finished: Bool) -> Void in
                    // set bottom offset back to original
                    self.bottomConstraint?.constant = beginOffset
                    
                    // determine how long we want to delay so the whole thing takes the expected time.
                    // ensure it's visible for at least 1 second
                    let delay = max(length.rawValue - 2 * Toast.fadeDuration, 1.0)
                    
                    // wait, then animate
                    UIView.animateWithDuration(Toast.fadeDuration, delay: delay, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
                        // animate fade out and bottom offset
                        self.alpha = 0
                        self.layoutIfNeeded()
                        }, completion: { (Bool) -> Void in
                            // remove from view
                            self.removeFromSuperview()
                            
                            // all done
                            completion()
                    })
            })
        }
    }
}
