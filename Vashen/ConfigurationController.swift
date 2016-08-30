//
//  ConfigurationController.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation

class ConfigurationController: UIViewController {
    
    var user: User!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var phone: UILabel!
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
        scrollView.contentSize.height = 900
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
    @IBAction func sendLogOut(sender: AnyObject) {
        do{
        ProfileReader.delete()
        try user.sendLogout()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("main") as! MainController
        self.presentViewController(nextViewController, animated:true, completion:nil)
        } catch {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("main") as! MainController
            self.presentViewController(nextViewController, animated:true, completion:nil)
        }
    }
    
    @IBAction func clickedCancel(sender: AnyObject) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Map", bundle:nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("reveal_controller") as! SWRevealViewController
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }

}
