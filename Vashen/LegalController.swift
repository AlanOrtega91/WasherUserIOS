//
//  LegalController.swift
//  Vashen
//
//  Created by Alan on 9/21/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit

class LegalController: UIViewController {

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
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelClick(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 

}
