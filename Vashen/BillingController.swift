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
    
    override func viewWillAppear(_ animated: Bool) {
        initValues()
        initView()
    }
    
    func initValues() {
        user = DataBase.readUser()
    }
    
    func initView() {
            billingName.text = user.billingName
            rfc.text = user.rfc
            billingAddress.text = user.billingAddress
    }

    @IBAction func clickedCancel(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
