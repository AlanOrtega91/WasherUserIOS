
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
    var sentNewCard = false
    
    @IBOutlet weak var cardNumber: UITextField!
    @IBOutlet weak var cvv: UITextField!
    @IBOutlet weak var month: UIButton!
    @IBOutlet weak var year: UIButton!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarLeftButton: UIBarButtonItem!
    @IBOutlet weak var navigationBarRightButton: UIBarButtonItem!
    
    var selected:Int = 0
    var months: [String] = ["01","02","03","04","05","06","07","08","09","10","11","12"]
    var years: [String] = []
    
    override func viewDidLoad() {
        initValues()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if sentNewCard {
            createAlertInfo()
        }
        
        configuraAño()
    }
    
    func configuraAño()
    {
        let date = Date()
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        var c = year
        var añosAEscribir = ""
        while c < year+10 {
            añosAEscribir = String(c)
            years.append(añosAEscribir.substring(from: añosAEscribir.index(añosAEscribir.startIndex, offsetBy: 2)))
            c = c + 1
        }
        
    }
    
    func initValues(){
        token = AppData.readToken()
        card = DataBase.readCard()
    }
    
    func initView(){
        picker.dataSource = self
        picker.delegate = self
        picker.isHidden = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        if card != nil {
            cardNumber.text = card.cardNumber
            let monthValue = card.expirationMonth
            let yearValue = card.expirationYear
            month.setTitle(String(monthValue), for: .normal)
            year.setTitle(String(yearValue), for: .normal)
        }
        if let barFont = UIFont(name: "PingFang TC", size: 17) {
            self.navigationBar.titleTextAttributes = [ NSFontAttributeName: barFont]
        }
        if let buttonFont = UIFont(name: "PingFang TC", size: 14) {
            self.navigationBarLeftButton.setTitleTextAttributes([ NSFontAttributeName: buttonFont], for: .normal)
            self.navigationBarRightButton.setTitleTextAttributes([ NSFontAttributeName: buttonFont], for: .normal)
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
        self.picker.isHidden = true
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch selected {
        case 0:
            month.setTitle(months[row], for: .normal)
        case 1:
            year.setTitle(years[row], for: .normal)
        default:
            return print("none")
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
        //TODO: Cambiar a produccion
        conekta.publicKey = "key_SwHV7ybQx64daTopMTQhZrw"
        conekta.collectDevice()

        let cardConekta = conekta.card()
        cardConekta?.setNumber(cardNumber.text, name: (user?.name)! + " " + (user?.lastName)!, cvc: cvv.text, expMonth: month.titleLabel!.text!, expYear: year.titleLabel!.text!)
        let tokenConekta = conekta.token()
        
        tokenConekta?.card = cardConekta
        sentNewCard = true
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "loading") as! LoadingController
        nextViewController.tokenConekta = tokenConekta
        nextViewController.action = LoadingController.NEW_CARD
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func maxCharSize(_ sender: AnyObject) {
        if (cvv.text?.characters.count)! > 4 {
            self.cvv.deleteBackward()
        }
    }
    @IBAction func clickedCancel(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func createAlertInfo(){
        let alert = UIAlertController(title: "Error", message: "Error con la tarjeta", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
