//
//  EditBillingController.swift
//  Vashen
//
//  Created by Alan on 8/1/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit

class EditBillingController: UIViewController {

    var user: User!
    var token: String!
    @IBOutlet weak var billingName: UITextField!
    @IBOutlet weak var rfc: UITextField!
    @IBOutlet weak var billingAddress: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.image = UIImage(named: "background")
        self.view.insertSubview(backgroundImage, atIndex: 0)
        initValues()
        initView()
    }
    
    func initValues() {
        user = DataBase.readUser()
    }
    
    func initView() {
        if user.billingName != nil {
            billingName.text = user.billingName
        }
        if user.rfc != nil {
            rfc.text = user.rfc
        }
        if user.billingAddress != nil {
            billingAddress.text = user.billingAddress
        }
    }
    
    @IBAction func changeData(sender: AnyObject) {
        if billingName.text == "" || rfc.text == "" || billingAddress == "" {
            //TODO: implement post alert
            return
        }
        user.billingAddress = billingAddress.text
        user.rfc = rfc.text
        user.billingName = billingName.text

        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("loading") as! LoadingController
        nextViewController.user = user
        nextViewController.action = LoadingController.EDIT_ACCOUNT
        self.presentViewController(nextViewController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickedCancel(sender: AnyObject) {
        let nextViewController = self.storyboard!.instantiateViewControllerWithIdentifier("billing") as! BillingController
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }

}
