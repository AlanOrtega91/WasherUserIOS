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
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        email.delegate = self
        phone.delegate = self
        password.delegate = self
        password2.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func sendContinue(_ sender: AnyObject) {
        self.view.endEditing(true)
        do{
        try reviewCredentials()
        try reviewPassword()
        let nextViewController = self.storyboard!.instantiateViewController(withIdentifier: "createPersonal") as! CreateAccountPersonalController
            
        nextViewController.email = email.text
        nextViewController.password = password.text
        nextViewController.phone = phone.text
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        } catch CreateAccountError.invalidCredentialsEmail{
            createAlertInfo(message: "Error con el Email")
        } catch CreateAccountError.invalidCredentialsPassword {
            createAlertInfo(message: "Error con la contrasena")
        } catch CreateAccountError.passwordDontMatch{
            createAlertInfo(message: "Contrasenas diferentes")
        } catch {
            createAlertInfo(message: "Error desconocido")
        }
    }
    
    func reviewCredentials() throws{
        if email.text! == "" || !(email.text?.contains("@"))! || !(email.text?.components(separatedBy: "@")[1].contains("."))!{
            throw CreateAccountError.invalidCredentialsEmail
        }
        if password.text == "" || NSString(string: password.text!).length < 6 {
            throw CreateAccountError.invalidCredentialsPassword
        }
    }
    
    func reviewPassword() throws {
        if password.text != password2.text {
            throw CreateAccountError.passwordDontMatch
        }
    }
    
    @IBAction func clickedCancel(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
            sendContinue("" as AnyObject)
            break
        default:
            break
        }
        return true
    }
    
    @IBAction func phoneMax(_ sender: AnyObject) {
        if (phone.text?.characters.count)! > 12 {
            self.phone.deleteBackward()
        }
    }
    func createAlertInfo(message:String){            let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
    }
    
    enum CreateAccountError: Error{
        case invalidCredentialsEmail
        case invalidCredentialsPassword
        case passwordDontMatch
    }
}
