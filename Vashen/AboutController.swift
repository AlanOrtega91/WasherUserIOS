//
//  AboutController.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation

class AboutController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarLeftButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

    @IBAction func clickedWasher(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: "http://washer.mx/")!)
    }
}
