//
//  ForgotPasswordController.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit

class ForgotPasswordController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarLeftButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let buttonFont = UIFont(name: "PingFang TC", size: 14) {
            self.navigationBarLeftButton.setTitleTextAttributes([ NSFontAttributeName: buttonFont], for: .normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickedCancel(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func clickedRecover(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
