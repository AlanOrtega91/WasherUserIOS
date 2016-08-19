//
//  CreateAccountPersonalController.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit

public class CreateAccountPersonalController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public var email:String!
    public var password:String!
    public var phone:String!
    @IBOutlet weak public var name: UITextField!
    @IBOutlet weak public var lastName: UITextField!
    @IBOutlet weak public var image: UIImageView!
    
    var encodedString: String!
    var token: String!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.image = UIImage(named: "background")
        self.view.insertSubview(backgroundImage, atIndex: 0)
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(CreateAccountPersonalController.openCamera))
        image.userInteractionEnabled = true
        image.addGestureRecognizer(tapGestureRecognizer)
    }
    

    @IBAction func sendRegistration(sender: AnyObject) {
        if name.text == "" || lastName.text == "" {
            postAlert("Nombre y apellido son necesarios")
            return
        }
        let nextViewController = self.storyboard!.instantiateViewControllerWithIdentifier("loading") as! LoadingController
        nextViewController.action = LoadingController.LOGIN
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
        let imageData = UIImagePNGRepresentation(imagePicked)
        encodedString = imageData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        self.dismissViewControllerAnimated(true, completion: nil);
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
    
    
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func clickedCancel(sender: AnyObject) {
        let nextViewController = self.storyboard!.instantiateViewControllerWithIdentifier("create_account") as! CreateAccountController
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }
}
