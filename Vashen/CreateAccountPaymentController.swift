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
    var card:Card!
    var sentNewCard = false
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        if sentNewCard {
            createAlertInfo()
        }
    }
    
    func initValues(){
        token = AppData.readToken()
    }
    
    func initView(){
        picker.dataSource = self
        picker.delegate = self
        picker.isHidden = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
        self.picker.isHidden = true
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch selected {
        case 0:
            NSLog("brand")
            month.setTitle(months[row], for: .normal)
        case 1:
            NSLog("types")
            year.setTitle(years[row], for: .normal)
        default:
            return NSLog("none")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch selected {
        case 0:
            return months[row]
        case 1:
            return years[row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
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
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @IBAction func dateClick(_ sender: UIButton) {
        self.view.endEditing(true)
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
        picker.isHidden = false
    }
    
    @IBAction func saveNewCard(_ sender: AnyObject) {
        let user = DataBase.readUser()
        let conekta = Conekta()
        conekta.delegate = self
        conekta.publicKey = "key_LqvrHkEMcS3rda65s4W4wRg"
        conekta.collectDevice()
        
        let cardConekta = conekta.card()
        cardConekta?.setNumber(cardNumber.text, name: user.name + " " + user.lastName, cvc: cvv.text, expMonth: month.titleLabel!.text!, expYear: year.titleLabel!.text!)
        let tokenConekta = conekta.token()
        
        tokenConekta?.card = cardConekta
        
        sentNewCard = true
        var storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "loading") as! LoadingController
        nextViewController.tokenConekta = tokenConekta
        nextViewController.action = LoadingController.NEW_CARD
        storyBoard = UIStoryboard(name: "Map", bundle: nil)
        let rootViewController = storyBoard.instantiateViewController(withIdentifier: "reveal_controller") as! SWRevealViewController
        self.navigationController?.setViewControllers([rootViewController,self], animated: true)
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func clickedCancel(_ sender: AnyObject) {
        let storyBoard = UIStoryboard(name: "Map", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "reveal_controller") as! SWRevealViewController
        self.navigationController?.setViewControllers([nextViewController], animated: true)
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    func createAlertInfo(message:String){
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
                let storyBoard = UIStoryboard(name: "Map", bundle: nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "reveal_controller") as! SWRevealViewController
                self.navigationController?.setViewControllers([nextViewController], animated: true)
                _ = self.navigationController?.popToRootViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
    }
    @IBAction func maxSizeCVV(_ sender: AnyObject) {
        if (cvv.text?.characters.count)! > 4 {
            self.cvv.deleteBackward()
        }
    }
    
    func createAlertInfo(){
        let alert = UIAlertController(title: "Error", message: "Error con la tarjeta", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
