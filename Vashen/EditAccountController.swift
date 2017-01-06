//
//  EditAccountController.swift
//  Vashen
//
//  Created by Alan on 8/1/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit

class EditAccountController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {
    
    var user = DataBase.readUser()

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarLeftButton: UIBarButtonItem!
    @IBOutlet weak var navigationBarRightButton: UIBarButtonItem!
    
    var imagePath: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        name.delegate = self
        lastName.delegate = self
        email.delegate = self
        phone.delegate = self
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
    
    func initView(){
        setUserImage()
        fillUserTextFields()
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(CreateAccountPersonalController.openCamera))
        userImage.isUserInteractionEnabled = true
        userImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setUserImage(){
        if user?.encodedImage != "" {
            if let image = User.readImageDataFromFile(name: (user?.encodedImage)!) {
                userImage.image = image
            }
        }
    }
    
    
    func fillUserTextFields(){
            name.text = user?.name
            lastName.text = user?.lastName
            email.text = user?.email
            phone.text = user?.phone
    }
    @IBAction func sendModifyData(_ sender: AnyObject) {
        if name.text == "" || lastName.text == "" {
            createAlertInfo(message: "Faltan datos")
            return
        }
        user?.name = name.text!
        user?.lastName = lastName.text!
        user?.email = email.text!
        user?.phone = phone.text!
        if imagePath != nil {
            user?.encodedImage = imagePath
        }
        do{
        try reviewCredentials()
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "loading") as! LoadingController
        nextViewController.user = user
        nextViewController.action = LoadingController.EDIT_ACCOUNT
        self.navigationController?.pushViewController(nextViewController, animated: true)
        } catch{
            createAlertInfo(message: "email o contrasena invalidos")
        }
        
    }
    
    func reviewCredentials() throws{
        if email.text! == "" || !(email.text?.contains("@"))! || !(email.text?.components(separatedBy: "@")[1].contains("."))!{
            throw EditAccountError.invalidCredentialsEmail
        }
    }
    
    @IBAction func clickOpenCamera(_ sender: AnyObject) {
        openCamera()
    }
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage imagePicked: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        userImage.image = imagePicked
        self.imagePath = User.saveImageToFileAndGetPath(image: imagePicked)
        self.dismiss(animated: true, completion: nil);
    }

    func createAlertInfo(message:String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case name:
            lastName.becomeFirstResponder()
            break
        case lastName:
            email.becomeFirstResponder()
            break
        case email:
            phone.becomeFirstResponder()
            break
        default:
            break
        }
        return true
    }
    
    @IBAction func phoneMaxLength(_ sender: AnyObject) {
        if (phone.text?.characters.count)! > 12 {
            self.phone.deleteBackward()
        }
    }
    @IBAction func clickedCancel(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    enum EditAccountError: Error{
        case invalidCredentialsEmail
    }
}
