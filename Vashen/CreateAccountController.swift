//
//  CreateAccountController.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit

public class CreateAccountController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var password2: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize.height = 600
        email.delegate = self
        phone.delegate = self
        password.delegate = self
        password2.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendContinue(sender: AnyObject) {
        self.view.endEditing(true)
        do{
        try reviewCredentials()
        try reviewPassword()
        let nextViewController = self.storyboard!.instantiateViewControllerWithIdentifier("createPersonal") as! CreateAccountPersonalController
            
        nextViewController.email = email.text
        nextViewController.password = password.text
        nextViewController.phone = phone.text
        
        self.presentViewController(nextViewController, animated:true, completion:nil)
        } catch {
            //TODO: set invalid for password length
            createAlertInfo("Error con credenciales")
        }
    }
    
    func reviewCredentials() throws{
        if email.text! == "" || !(email.text?.containsString("@"))! || !(email.text?.componentsSeparatedByString("@")[1].containsString("."))!{
            throw Error.invalidCredentialsEmail
        }
        if password.text == "" || NSString(string: password.text!).length < 6 {
            throw Error.invalidCredentialsPassword
        }
    }
    
    func reviewPassword() throws {
        if password.text != password2.text {
            throw Error.passwordDontMatch
        }
    }
    
    @IBAction func clickedCancel(sender: AnyObject) {
        let nextViewController = self.storyboard!.instantiateViewControllerWithIdentifier("main") as! MainController
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case email:
            phone.becomeFirstResponder()
            break
        case phone:
            password.becomeFirstResponder()
            break
        case password:
            password2.becomeFirstResponder()
            break
        case password2:
            sendContinue("")
            break
        default:
            break
        }
        return true
    }
    
    func createAlertInfo(message:String){
        dispatch_async(dispatch_get_main_queue(), {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    enum Error: ErrorType{
        case invalidCredentialsEmail
        case invalidCredentialsPassword
        case passwordDontMatch
    }
}
