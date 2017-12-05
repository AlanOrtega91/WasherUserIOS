//
//  LoginController.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit
import Firebase

public class LoginController: UIViewController {

    @IBOutlet weak var email: UITextField!
    public var emailSet:String = ""
    @IBOutlet weak var password: UITextField!
    public var passwordSet:String = ""
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarLeftButton: UIBarButtonItem!
    @IBOutlet weak var navigationBarRightButton: UIBarButtonItem!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        if let barFont = UIFont(name: "PingFang TC", size: 17) {
            self.navigationBar.titleTextAttributes = [ NSFontAttributeName: barFont]
        }
        if let buttonFont = UIFont(name: "PingFang TC", size: 14) {
            self.navigationBarLeftButton.setTitleTextAttributes([ NSFontAttributeName: buttonFont], for: .normal)
            self.navigationBarRightButton.setTitleTextAttributes([ NSFontAttributeName: buttonFont], for: .normal)
        }
        connectToFcm()
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
    
    @IBAction func cancelClicked(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func sendLogin(_ sender: AnyObject) {
        do{
            try reviewCredentials()
        } catch LoginError.invalidCredentialsEmail{
            createAlertInfo(message: "Error con el Email")
        } catch LoginError.invalidCredentialsPassword {
            createAlertInfo(message: "Error con la contrasena")
        } catch {
            createAlertInfo(message: "Error desconocido")
        }
        let nextViewController = self.storyboard!.instantiateViewController(withIdentifier: "loading") as! LoadingController
        nextViewController.action = LoadingController.LOGIN
        nextViewController.email = email.text!
        nextViewController.password = password.text!
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func reviewCredentials() throws{
        if email.text! == "" || !(email.text?.contains("@"))! || !(email.text?.components(separatedBy: "@")[1].contains("."))!{
            throw LoginError.invalidCredentialsEmail
        }
        if password.text == "" || NSString(string: password.text!).length < 6 {
            throw LoginError.invalidCredentialsPassword
        }
    }
    
    
    func createAlertInfo(message:String){
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(String(describing: error))")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    enum LoginError: Error{
        case invalidCredentialsEmail
        case invalidCredentialsPassword
        case passwordDontMatch
    }
}
