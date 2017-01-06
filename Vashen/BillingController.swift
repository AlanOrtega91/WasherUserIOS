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
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarLeftButton: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        initValues()
        initView()
    }
    
    func initValues() {
        user = DataBase.readUser()
    }
    
    func initView() {
        if user.billingName != "" {
            billingName.text = user.billingName
        }
        if user.rfc != "" {
            rfc.text = user.rfc
        }
        if user.billingAddress != "" {
            billingAddress.text = user.billingAddress
        }
        if let barFont = UIFont(name: "PingFang TC", size: 17) {
            self.navigationBar.titleTextAttributes = [ NSFontAttributeName: barFont]
        }
        if let buttonFont = UIFont(name: "PingFang TC", size: 14) {
            self.navigationBarLeftButton.setTitleTextAttributes([ NSFontAttributeName: buttonFont], for: .normal)
        }
    }

    @IBAction func clickedCancel(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
