//
//  AddCarController.swift
//  Vashen
//
//  Created by Alan on 8/1/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit

class AddCarController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {

    @IBOutlet weak var plates: UITextField!
    @IBOutlet weak var brand: UIButton!
    @IBOutlet weak var type: UIButton!
    @IBOutlet weak var color: UIButton!
    @IBOutlet weak var picker: UIPickerView!
    var token:String!
    var selected:Int = 0
    var selectedColor:String = ""
    var selectedBrand:String = ""
    var selectedType:Int = 0
    
    var brands: [String] = ["toyota","Volvo","Ford"]
    var types: [String] = ["Moto","Coche Chico","Coche Grande","Camioneta Chica","Camioneta Grande"]
    var colors: [String] = ["Rojo","Azul","Negro"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.image = UIImage(named: "background")
        self.view.insertSubview(backgroundImage, atIndex: 0)
        token = AppData.readToken()
        picker.dataSource = self
        picker.delegate = self
        picker.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch selected {
        case 0:
            NSLog("brand")
            brand.setTitle(brands[row], forState: .Normal)
            selectedBrand = brands[row]
        case 1:
            NSLog("types")
            type.setTitle(types[row], forState: .Normal)
            selectedType = row
        case 2:
            NSLog("colors")
            color.setTitle(colors[row], forState: .Normal)
            selectedColor = colors[row]
        default:
            return NSLog("none")
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch selected {
        case 0:
            return brands[row]
        case 1:
            return types[row]
        case 2:
            return colors[row]
        default:
            return ""
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch selected {
        case 0:
            return brands.count
        case 1:
            return types.count
        case 2:
            return colors.count
        default:
            return 0
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @IBAction func optionClick(sender: UIButton) {
        switch sender {
        case brand:
            selected = 0
            picker.reloadAllComponents()
            break
        case type:
            selected = 1
             picker.reloadAllComponents()
            break
        case color:
            selected = 2
             picker.reloadAllComponents()
            break
        default:
            break
        }
        picker.hidden = false
    }
    
    
    @IBAction func saveNewCar(sender: AnyObject) {
        let car = Car()
        car.plates = plates.text
        car.model = "Car"
        car.color = selectedColor
        car.type = String(selectedType)
        car.brand = selectedBrand
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("loading") as! LoadingController
        nextViewController.car = car
        nextViewController.action = LoadingController.NEW_CAR
        self.presentViewController(nextViewController, animated: true, completion: nil)
    }
    
    @IBAction func clickedCancel(sender: AnyObject) {
        let nextViewController = self.storyboard!.instantiateViewControllerWithIdentifier("cars") as! CarsController
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }

}
