//
//  CreateAccountPersonalController.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit

public class CreateAccountPersonalController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate {

    public var email:String!
    public var password:String!
    public var phone:String!
    @IBOutlet weak public var name: UITextField!
    @IBOutlet weak public var lastName: UITextField!
    @IBOutlet weak public var image: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var encodedString: String!
    var token: String!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize.height = 600
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(CreateAccountPersonalController.openCamera))
        image.userInteractionEnabled = true
        image.addGestureRecognizer(tapGestureRecognizer)
        name.delegate = self
        lastName.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case name:
            lastName.becomeFirstResponder()
            break
        case lastName:
            sendRegistration("")
            break
        default:
            break
        }
        return true
    }
    

    @IBAction func sendRegistration(sender: AnyObject) {
        if name.text == "" || lastName.text == "" {
            createAlertInfo("Nombre y apellido son necesarios")
            return
        }
        let nextViewController = self.storyboard!.instantiateViewControllerWithIdentifier("loading") as! LoadingController
        nextViewController.email = email
        nextViewController.password = password
        nextViewController.phone = phone
        nextViewController.name = name.text
        nextViewController.lastName = lastName.text
        nextViewController.image = image.image
        nextViewController.encodedImage = encodedString
        nextViewController.action = LoadingController.REGISTER
        self.presentViewController(nextViewController, animated: true, completion: nil)
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
        image.image = imagePicked
        let imageData = UIImageJPEGRepresentation(imagePicked, 1.0)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // do some task
            self.encodedString = imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
            print(self.encodedString)
        });
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func createAlertInfo(message:String){
        dispatch_async(dispatch_get_main_queue(), {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func clickedCancel(sender: AnyObject) {
        let nextViewController = self.storyboard!.instantiateViewControllerWithIdentifier("create_account") as! CreateAccountController
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }
}
