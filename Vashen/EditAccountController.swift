//
//  EditAccountController.swift
//  Vashen
//
//  Created by Alan on 8/1/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit

class EditAccountController: UIViewController {
    
    var user: User!

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
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
        scrollView.contentSize.height = 1000
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
            //TODO: Implement postAlert
            return
        }
        user.name = name.text
        user.lastName = lastName.text
        user.email = email.text
        user.phone = phone.text
        do{
        try reviewCredentials()
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("loading") as! LoadingController
        nextViewController.user = user
        nextViewController.action = LoadingController.EDIT_ACCOUNT
        self.presentViewController(nextViewController, animated: true, completion: nil)
        } catch{
            //TODO: PostAlert
        }
        
    }
    
    func reviewCredentials() throws{
        if email.text! == "" || !(email.text?.containsString("@"))! || !(email.text?.componentsSeparatedByString("@")[1].containsString("."))!{
            throw Error.invalidCredentialsEmail
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickedCancel(sender: AnyObject) {
        let nextViewController = self.storyboard!.instantiateViewControllerWithIdentifier("configuration") as! ConfigurationController
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }

    enum Error: ErrorType{
        case invalidCredentialsEmail
    }
}
