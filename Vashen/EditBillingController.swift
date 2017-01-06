//
//  EditBillingController.swift
//  Vashen
//
//  Created by Alan on 8/1/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit

class EditBillingController: UIViewController, UITextFieldDelegate {

    var user: User!
    var token: String!
    @IBOutlet weak var billingName: UITextField!
    @IBOutlet weak var rfc: UITextField!
    @IBOutlet weak var billingAddress: UITextField!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarLeftButton: UIBarButtonItem!
    @IBOutlet weak var navigationBarRightButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initValues()
        initView()
    }
    
    func initValues() {
        user = DataBase.readUser()
    }
    
    func initView() {
        self.billingName.delegate = self
        self.rfc.delegate = self
        self.billingAddress.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        if user.billingName != "" {
            billingName.text = user.billingName
        }
        if user.rfc != "" {
            rfc.text = user.rfc
        }
        if user.billingAddress != "" {
            billingAddress.text = user.billingAddress
        }
        if let buttonFont = UIFont(name: "PingFang TC", size: 10) {
            self.navigationBarLeftButton.setTitleTextAttributes([ NSFontAttributeName: buttonFont], for: .normal)
            self.navigationBarRightButton.setTitleTextAttributes([ NSFontAttributeName: buttonFont], for: .normal)
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func changeData(_ sender: AnyObject) {
        if billingName.text! == "" || rfc.text! == "" || billingAddress.text == "" {
            self.createAlertInfo(message: "Datos incompletos")
            return
        }
        user.billingAddress = billingAddress.text!
        user.rfc = rfc.text!
        user.billingName = billingName.text!

        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "loading") as! LoadingController
        nextViewController.user = user
        nextViewController.action = LoadingController.EDIT_ACCOUNT
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func createAlertInfo(message:String){
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case billingName:
            rfc.becomeFirstResponder()
            break
        case rfc:
            billingAddress.becomeFirstResponder()
            break
        case billingAddress:
            changeData("" as AnyObject)
            break
        default:
            break
        }
        return true
    }
    
    @IBAction func clickedCancel(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }

}
