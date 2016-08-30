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
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @IBAction func clickedCancel(sender: AnyObject) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Map", bundle:nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("reveal_controller") as! SWRevealViewController
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }
    
}