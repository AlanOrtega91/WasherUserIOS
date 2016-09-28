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
    
    override func viewWillAppear(_ animated: Bool) {
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
        let imageData = NSData(base64Encoded: user.encodedImage, options: .ignoreUnknownCharacters)
        userImage.image = UIImage(data: imageData! as Data)
    }
    
    func fillUserTextFields(){
        if user.name != nil {
            name.text = String(user.name)
        }
        if user.lastName != nil {
            lastName.text = String(user.lastName)
        }
        if user.email != nil {
            email.text = String(user.email)
        }
        if user.phone != nil {
            phone.text = String(user.phone)
        }
    }
    
    @IBAction func sendLogOut(_ sender: AnyObject) {
        do{
            ProfileReader.delete()
            try user.sendLogout()
        } catch {
            print("Error logging out")
        }
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "main")
        self.navigationController?.setViewControllers([nextViewController], animated: true)
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func clickedCancel(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }

}
