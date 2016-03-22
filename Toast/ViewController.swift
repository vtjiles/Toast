//
//  ViewController.swift
//  Toast
//
//  Created by Jason Iles on 3/22/16.
//  Copyright © 2016 jiles. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var text: UITextField!
    @IBOutlet weak var push: UISwitch!
    @IBOutlet weak var btn: UIButton!
    
    @IBOutlet weak var short: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onTapBtn(sender: UIButton) {
        var toastText = text.text
        
        if toastText == nil || toastText?.characters.count == 0 {
            toastText = "You need to set text to make a toast."
        }
        
        Toast.makeText(toastText!, length: short.on ? .Short : .Long)
        
        if push.on {
            self.navigationController?.performSegueWithIdentifier("show", sender: nil)
        }
    }

}

