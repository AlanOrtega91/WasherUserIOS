//
//  CreateAccountPaymentController.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit

class CreateAccountPaymentController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate, UITextFieldDelegate {

    var token:String!
    var card:UserCard!
    var clientPaymentToken:String!
    
    @IBOutlet weak var cardNumber: UITextField!
    @IBOutlet weak var cvv: UITextField!
    @IBOutlet weak var month: UIButton!
    @IBOutlet weak var year: UIButton!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var selected:Int = 0
    var months: [String] = ["01","02","03","04","05","06","07","08","09","10","11","12"]
    var years: [String] = ["16","17","18","19","20","21","22","23"]
    
    override func viewDidLoad() {
        initValues()
        initView()
        let getPaymentTokenThread:NSThread = NSThread(target: self, selector:#selector(initThreads), object: nil)
        getPaymentTokenThread.start()
    }
    
    func initValues(){
        token = AppData.readToken()
    }
    
    func initView(){
        scrollView.contentSize.height = 600
        picker.dataSource = self
        picker.delegate = self
        picker.hidden = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func initThreads(){
        do {
            clientPaymentToken = try Payment.getPaymentToken(token)
            AppData.savePaymentToken(clientPaymentToken)
        } catch {
            
        }
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
