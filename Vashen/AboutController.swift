//
//  AboutController.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation

class AboutController: UIViewController {
    
    @IBAction func clickedCancel(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func clickedWasher(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: "http://washer.mx/")!)
    }
}
