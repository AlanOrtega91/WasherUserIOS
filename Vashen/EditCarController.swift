//
//  EditCarController.swift
//  Vashen
//
//  Created by Alan on 8/17/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit

class EditCarController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {

    @IBOutlet weak var plates: UITextField!
    @IBOutlet weak var brand: UIButton!
    @IBOutlet weak var type: UIButton!
    @IBOutlet weak var color: UIButton!
    @IBOutlet weak var picker: UIPickerView!
    var selected:Int = 0
    var selectedColor:String = ""
    var selectedBrand:String = ""
    var selectedType:Int = 0
    var selectedCarIndex:Int = 0
    var selectedVehicleId: Int = 0
    var cars:Array<Car> = Array<Car>()
    
    var brands: [String] = ["toyota","Volvo","Ford"]
    var types: [String] = ["Moto","Coche Chico","Coche Grande","Camioneta Chica","Camioneta Grande"]
    var colors: [String] = ["Rojo","Azul","Negro"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.dataSource = self
        picker.delegate = self
        picker.hidden = true
        
        initValues()
        initView()

        // Do any additional setup after loading the view.
    }
    
    func initView(){
        let car = cars[selectedCarIndex]
        type.titleLabel?.text = car.type
        color.titleLabel?.text = car.color
        brand.titleLabel?.text = car.brand
        plates.text = car.plates
    }
    
    func initValues(){
        cars = DataBase.readCars()
        for car in cars {
            if String(car.id) == String(selectedVehicleId) {
                selectedCarIndex = cars.indexOf({$0.id == car.id})!
                break
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch selected {
        case 0:
            NSLog("brand")
            brand.titleLabel?.text = brands[row]
            selectedBrand = brands[row]
        case 1:
            NSLog("types")
            type.titleLabel?.text = types[row]
            selectedType = row
        case 2:
            NSLog("colors")
            color.titleLabel?.text = colors[row]
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
    
    @IBAction func sendEdit(sender: AnyObject) {
        let car = Car()
        car.plates = plates.text
        car.model = "Car"
        car.color = selectedColor
        car.type = String(selectedType)
        car.brand = selectedBrand
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("loading") as! LoadingController
        nextViewController.car = car
        nextViewController.selectedIndex = selectedCarIndex
        nextViewController.action = LoadingController.EDIT_CAR
        self.presentViewController(nextViewController, animated: true, completion: nil)
    }
    
    @IBAction func clickedCancel(sender: AnyObject) {
        let nextViewController = self.storyboard!.instantiateViewControllerWithIdentifier("cars") as! CarsController
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }

}
