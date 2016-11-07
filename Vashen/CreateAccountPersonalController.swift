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
    
    var encodedString: String!
    var token: String!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(CreateAccountPersonalController.openCamera))
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(tapGestureRecognizer)
        name.delegate = self
        lastName.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case name:
            lastName.becomeFirstResponder()
            break
        case lastName:
            sendRegistration("" as AnyObject)
            break
        default:
            break
        }
        return true
    }
    

    @IBAction func sendRegistration(_ sender: AnyObject) {
        if name.text == "" || lastName.text == "" {
            createAlertInfo(message: "Nombre y apellido son necesarios")
            return
        }
        let nextViewController = self.storyboard!.instantiateViewController(withIdentifier: "loading") as! LoadingController
        nextViewController.email = email
        nextViewController.password = password
        nextViewController.phone = phone
        nextViewController.name = name.text
        nextViewController.lastName = lastName.text
        nextViewController.image = image.image
        nextViewController.encodedImage = encodedString
        nextViewController.action = LoadingController.REGISTER
        self.navigationController?.pushViewController(nextViewController, animated: true)
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
        image.image = imagePicked
        let imageData = UIImageJPEGRepresentation(imagePicked, 0.3)
        DispatchQueue.global(qos: .background).async {
            self.encodedString = imageData!.base64EncodedString()
        }
        self.dismiss(animated: true, completion: nil);
    }
    
    func createAlertInfo(message:String){
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
    }

    

    @IBAction func clickedCancel(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
