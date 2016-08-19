//
//  CreateAccountController.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit

public class CreateAccountController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak public var email: UITextField!
    @IBOutlet weak public var phone: UITextField!
    @IBOutlet weak public var password: UITextField!
    @IBOutlet weak public var password2: UITextField!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.image = UIImage(named: "background.png")
        self.view.insertSubview(backgroundImage, atIndex: 0)
        email.delegate = self
        phone.delegate = self
        password.delegate = self
        password2.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreateAccountController.dismissKeyboard))
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
            postAlert("Error con credenciales")
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
    
    private func postAlert(message:String){
        let toastLabel = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - 150, self.view.frame.size.height-100, 300, 35))
        toastLabel.backgroundColor = UIColor.blackColor()
        toastLabel.textColor = UIColor.whiteColor()
        toastLabel.textAlignment = NSTextAlignment.Center;
        self.view.addSubview(toastLabel)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        
        UIView.animateWithDuration(4.0,delay: 0.1,options: .CurveEaseOut, animations: {toastLabel.alpha = 0.0}, completion: nil)
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
    
    enum Error: ErrorType{
        case invalidCredentialsEmail
        case invalidCredentialsPassword
        case passwordDontMatch
    }
}
