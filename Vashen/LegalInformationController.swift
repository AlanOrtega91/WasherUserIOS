//
//  LegalInformationController.swift
//  Vashen
//
//  Created by Alan on 9/21/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit

class LegalInformationController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarLeftButton: UIBarButtonItem!
    
    @IBOutlet weak var informacion: UITextView!
    var texto: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let barFont = UIFont(name: "PingFang TC", size: 17) {
            self.navigationBar.titleTextAttributes = [ NSFontAttributeName: barFont]
        }
        if let buttonFont = UIFont(name: "PingFang TC", size: 14) {
            self.navigationBarLeftButton.setTitleTextAttributes([ NSFontAttributeName: buttonFont], for: .normal)
        }
        // Do any additional setup after loading the view.
        informacion.text = texto
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelClick(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }

}
