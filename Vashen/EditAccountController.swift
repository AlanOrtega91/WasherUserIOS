//
//  EditAccountController.swift
//  Vashen
//
//  Created by Alan on 8/1/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit

class EditAccountController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {
    
    var user: User!

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var encodedString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initValues()
        initView()
        name.delegate = self
        lastName.delegate = self
        email.delegate = self
        phone.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func initValues(){
        user = DataBase.readUser()
    }
    
    func initView(){
        readUserImage()
        fillUserTextFields()
        scrollView.contentSize.height = 1200
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(CreateAccountPersonalController.openCamera))
        userImage.isUserInteractionEnabled = true
        userImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func readUserImage(){
        if user.encodedImage != nil {
            setUserImage()
        }
    }
    
    func setUserImage(){
        let imageData = NSData(base64Encoded: user.encodedImage, options: .ignoreUnknownCharacters)
        userImage.image = UIImage(data: imageData! as Data)
    }
    
    func fillUserTextFields(){
        if user.name != nil {
            name.text = user.name
        }
        if user.lastName != nil {
            lastName.text = user.lastName
        }
        if user.email != nil {
            email.text = user.email
        }
        if user.phone != nil {
            phone.text = user.phone
        }
    }
    @IBAction func sendModifyData(_ sender: AnyObject) {
        if name.text == "" || lastName.text == "" {
            createAlertInfo(message: "Faltan datos")
            return
        }
        user.name = name.text
        user.lastName = lastName.text
        user.email = email.text
        user.phone = phone.text
        user.encodedImage = encodedString
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
        let imageData = UIImageJPEGRepresentation(imagePicked, 1.0)
        DispatchQueue.global(qos: .background).async {
            self.encodedString = imageData?.base64EncodedString()
        }
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
