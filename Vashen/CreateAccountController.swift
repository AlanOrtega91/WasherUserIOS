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
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarLeftButton: UIBarButtonItem!
    @IBOutlet weak var navigationBarRightButton: UIBarButtonItem!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        email.delegate = self
        phone.delegate = self
        password.delegate = self
        password2.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        if let barFont = UIFont(name: "PingFang TC", size: 17) {
            self.navigationBar.titleTextAttributes = [ NSFontAttributeName: barFont]
        }
        if let buttonFont = UIFont(name: "PingFang TC", size: 14) {
            self.navigationBarLeftButton.setTitleTextAttributes([ NSFontAttributeName: buttonFont], for: .normal)
            self.navigationBarRightButton.setTitleTextAttributes([ NSFontAttributeName: buttonFont], for: .normal)
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func sendContinue(_ sender: AnyObject) {
        self.view.endEditing(true)
        do{
        try reviewCredentials()
        try reviewPassword()
        try revisaDatos()
        let nextViewController = self.storyboard!.instantiateViewController(withIdentifier: "createPersonal") as! CreateAccountPersonalController
            
        nextViewController.email = email.text
        nextViewController.password = password.text
        nextViewController.phone = phone.text
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        } catch CreateAccountError.invalidCredentialsEmail{
            createAlertInfo(message: "Error con el Email")
        } catch CreateAccountError.invalidCredentialsPassword {
            createAlertInfo(message: "Error con la contraseña: Debe contener al menos 6 caracteres")
        } catch CreateAccountError.passwordDontMatch{
            createAlertInfo(message: "Contraseñas diferentes")
        } catch CreateAccountError.telefonoInvalido {
            createAlertInfo(message: "El telefono debe de ser de al menos 10 digitos")
        }
        catch {
            createAlertInfo(message: "Error desconocido")
        }
    }
    
    func reviewCredentials() throws{
        if email.text! == "" || !(email.text?.contains("@"))! || !(email.text?.components(separatedBy: "@")[1].contains("."))!{
            throw CreateAccountError.invalidCredentialsEmail
        }
        if password.text == "" || (password.text?.characters.count)! < 6 {
            throw CreateAccountError.invalidCredentialsPassword
        }
    }
    
    func reviewPassword() throws {
        if password.text != password2.text {
            throw CreateAccountError.passwordDontMatch
        }
    }
    
    func revisaDatos() throws {
        if phone.text?.characters.count != 10 {
            throw CreateAccountError.telefonoInvalido
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
    func createAlertInfo(message:String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
    }
    
    enum CreateAccountError: Error{
        case invalidCredentialsEmail
        case invalidCredentialsPassword
        case passwordDontMatch
        case telefonoInvalido
    }
}
