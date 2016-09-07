//
//  EditAccountController.swift
//  Vashen
//
//  Created by Alan on 8/1/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit

class EditAccountController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
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
    }
    
    func initValues(){
        user = DataBase.readUser()
    }
    
    func initView(){
        readUserImage()
        fillUserTextFields()
        scrollView.contentSize.height = 600
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(CreateAccountPersonalController.openCamera))
        userImage.userInteractionEnabled = true
        userImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func readUserImage(){
        if user.encodedImage != nil {
            setUserImage()
        }
    }
    
    func setUserImage(){
        let imageData = NSData(base64EncodedString: user.encodedImage, options: .IgnoreUnknownCharacters)
        userImage.image = UIImage(data: imageData!)
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
    @IBAction func sendModifyData(sender: AnyObject) {
        if name.text == "" || lastName.text == "" {
            createAlertInfo("Faltan datos")
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
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("loading") as! LoadingController
        nextViewController.user = user
        nextViewController.action = LoadingController.EDIT_ACCOUNT
        self.presentViewController(nextViewController, animated: true, completion: nil)
        } catch{
            createAlertInfo("email o contrasena invalidos")
        }
        
    }
    
    func reviewCredentials() throws{
        if email.text! == "" || !(email.text?.containsString("@"))! || !(email.text?.componentsSeparatedByString("@")[1].containsString("."))!{
            throw Error.invalidCredentialsEmail
        }
    }
    
    @IBAction func clickOpenCamera(sender: AnyObject) {
        openCamera()
    }
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage imagePicked: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        userImage.image = imagePicked
        let imageData = UIImageJPEGRepresentation(imagePicked, 1.0)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.encodedString = imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        });
        self.dismissViewControllerAnimated(true, completion: nil);
    }

    func createAlertInfo(message:String){
        dispatch_async(dispatch_get_main_queue(), {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        })
    }
    
    @IBAction func clickedCancel(sender: AnyObject) {
        let nextViewController = self.storyboard!.instantiateViewControllerWithIdentifier("configuration") as! ConfigurationController
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }

    enum Error: ErrorType{
        case invalidCredentialsEmail
    }
}
