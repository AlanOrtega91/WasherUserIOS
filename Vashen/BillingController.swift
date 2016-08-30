//
//  BillingController.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation

class BillingController: UIViewController {
    
    var user: User!
    
    @IBOutlet weak var billingName: UILabel!
    @IBOutlet weak var rfc: UILabel!
    @IBOutlet weak var billingAddress: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

    @IBAction func clickedCancel(sender: AnyObject) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Map", bundle:nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("reveal_controller") as! SWRevealViewController
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }
}
