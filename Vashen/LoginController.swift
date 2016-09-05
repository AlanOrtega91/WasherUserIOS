//
//  LoginController.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit

public class LoginController: UIViewController {

    @IBOutlet weak var email: UITextField!
    public var emailSet:String = ""
    @IBOutlet weak var password: UITextField!
    public var passwordSet:String = ""
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        if emailSet != "" {
            email.text = emailSet
        }
        if passwordSet != "" {
            password.text = passwordSet
        }
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelClicked(sender: AnyObject) {
        let nextViewController = self.storyboard!.instantiateViewControllerWithIdentifier("main") as! MainController
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }

    @IBAction func sendLogin(sender: AnyObject) {
        let nextViewController = self.storyboard!.instantiateViewControllerWithIdentifier("loading") as! LoadingController
        nextViewController.action = LoadingController.LOGIN
        nextViewController.email = email.text!
        nextViewController.password = password.text!
        self.presentViewController(nextViewController, animated: true, completion: nil)
    }
}
