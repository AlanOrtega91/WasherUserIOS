//
//  PaymentController.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation

class PaymentController: UIViewController{
    
    var card: UserCard!
    @IBOutlet weak var cardNumber: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        initValues()
        initView()
    }
    
    func initValues(){
        card = DataBase.readCard()
    }
    
    func initView() {
        if card != nil {
            cardNumber.text = card.cardNumber
        }
    }
    
    @IBAction func clickedCancel(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
}
