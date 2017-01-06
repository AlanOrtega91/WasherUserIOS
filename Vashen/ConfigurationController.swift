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
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarLeftButton: UIBarButtonItem!
    
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
        if let barFont = UIFont(name: "PingFang TC", size: 17) {
            self.navigationBar.titleTextAttributes = [ NSFontAttributeName: barFont]
        }
        if let buttonFont = UIFont(name: "PingFang TC", size: 14) {
            self.navigationBarLeftButton.setTitleTextAttributes([ NSFontAttributeName: buttonFont], for: .normal)
        }
    }
    
    func readUserImage(){
        if user.encodedImage != "" {
            if let image = User.readImageDataFromFile(name: user.encodedImage) {
                userImage.image = image
            }
        }
    }
    
    func fillUserTextFields(){
            name.text = String(user.name)
            lastName.text = String(user.lastName)
            email.text = String(user.email)
            phone.text = String(user.phone)
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
