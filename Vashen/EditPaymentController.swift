//
//  EditPaymentController.swift
//  Vashen
//
//  Created by Alan on 8/19/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation

class EditPaymentController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {

    var token:String!
    var card:UserCard!
    var clientPaymentToken:String!
    
    @IBOutlet weak var cardNumber: UITextField!
    @IBOutlet weak var cvv: UITextField!
    @IBOutlet weak var month: UIButton!
    @IBOutlet weak var year: UIButton!
    @IBOutlet weak var picker: UIPickerView!
    
    var selected:Int = 0
    var months: [String] = ["01","02","03","04","05","06","07","08","09","10","11","12"]
    var years: [String] = ["16","17","18","19","20","21","22","23"]
    
    override func viewDidLoad() {
        initValues()
        initView()
    }
    
    func initValues(){
        clientPaymentToken = AppData.readPaymentToken()
        token = AppData.readToken()
        card = DataBase.readCard()
    }
    
    func initView(){
        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.image = UIImage(named: "background")
        self.view.insertSubview(backgroundImage, atIndex: 0)
        picker.dataSource = self
        picker.delegate = self
        picker.hidden = true
        cardNumber.text = card.cardNumber
        
        let monthValue = card.expirationDate.substringToIndex(card.expirationDate.startIndex.advancedBy(2))
        let yearValue = card.expirationDate.substringFromIndex(card.expirationDate.startIndex.advancedBy(5))
        month.setTitle(monthValue, forState: .Normal)
        year.setTitle(yearValue, forState: .Normal)
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch selected {
        case 0:
            NSLog("brand")
            month.setTitle(months[row], forState: .Normal)
        case 1:
            NSLog("types")
            year.setTitle(years[row], forState: .Normal)
        default:
            return NSLog("none")
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch selected {
        case 0:
            return months[row]
        case 1:
            return years[row]
        default:
            return ""
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch selected {
        case 0:
            return months.count
        case 1:
            return years.count
        default:
            return 0
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @IBAction func dateClick(sender: UIButton) {
        switch sender {
        case month:
            selected = 0
            picker.reloadAllComponents()
            break
        case year:
            selected = 1
            picker.reloadAllComponents()
            break
        default:
            break
        }
        picker.hidden = false
    }
    
    @IBAction func saveNewCard(sender: AnyObject) {
        let card = BTCard(number: cardNumber.text!, expirationMonth: month.titleLabel!.text!, expirationYear: year.titleLabel!.text!, cvv: cvv.text)
        card.shouldValidate = true
        
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("loading") as! LoadingController
        nextViewController.card = card
        nextViewController.action = LoadingController.NEW_CARD
        self.presentViewController(nextViewController, animated: true, completion: nil)
    }
    
    @IBAction func clickedCancel(sender: AnyObject) {
        let nextViewController = self.storyboard!.instantiateViewControllerWithIdentifier("payment") as! PaymentController
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }
}
