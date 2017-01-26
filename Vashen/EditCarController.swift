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
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarLeftButton: UIBarButtonItem!
    @IBOutlet weak var navigationBarRightButton: UIBarButtonItem!
    var selected:Int = 0
    var selectedColor:String = ""
    var selectedBrand:String = ""
    var selectedType:Int = 0
    var selectedCarIndex:Int = 0
    var selectedVehicleId: Int = 0
    var car:Car!
    
    var brands: [String] = [
        "Acura",
        "Alfa Romeo",
        "Aston Martin",
        "Audi",
        "BAIC",
        "BAJAJ",
        "Benelli",
        "Bentley",
        "Beta",
        "Bimota",
        "BMW",
        "Buick",
        "Cadillac",
        "Can-am",
        "Carabela",
        "Chevrolet",
        "Chrysler",
        "Dinamo",
        "Dodge",
        "Ducati",
        "Ferrari",
        "Fiat",
        "Ford",
        "Gasgas",
        "GMC",
        "Harley-Davidson",
        "Honda",
        "Husqvarna",
        "Hyundai",
        "Infiniti",
        "Islo",
        "Italika",
        "Izuka",
        "Jaguar",
        "Jeep",
        "Kawasaki",
        "Keeway",
        "Kia",
        "KTM",
        "Kurazai",
        "KYMCO",
        "Lamborghini",
        "Land Rover",
        "Lincoln",
        "LML",
        "Maserati",
        "Mazda",
        "McLaren Automotive",
        "Mecatecno",
        "Mercedes Benz",
        "MV Agusta",
        "MINI",
        "Mitsubishi",
        "Nissan",
        "Peugeot",
        "Polaris",
        "Porsche",
        "Quadro",
        "RAM",
        "Renault",
        "Sachs",
        "SEAT",
        "Sherco",
        "Smart",
        "Subaru",
        "Suzuki",
        "Tesla",
        "Toyota",
        "Triumph",
        "TVS",
        "Volkswagen",
        "Volvo",
        "Vyrus",
        "XPA",
        "Yamaha"]
    
    var types: [String] = [
        "Moto",
        "Auto",
        "Camioneta Chica",
        "Camioneta Grande"]
    var colors: [String] = [
        "Azul",
        "Rojo",
        "Morado",
        "Verde",
        "Negro",
        "Blanco",
        "Rosa",
        "Naranja",
        "Amarillo",
        "Gris",
        "Plateado",
        "Purpura",
        "Cafe",
        "Dorado"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.dataSource = self
        picker.delegate = self
        picker.isHidden = true
        
        initView()
    }
    
    func initView(){
        type.setTitle(types[Int(car.type)! - 1], for: .normal)
        color.setTitle(car.color, for: .normal)
        brand.setTitle(car.brand, for: .normal)
        plates.text = car.plates
        
        selectedColor = car.color
        selectedBrand = car.brand
        selectedType = Int(car.type)! - 1

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
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
            NSLog("brand")
            brand.setTitle(brands[row], for: .normal)
            selectedBrand = brands[row]
        case 1:
            NSLog("types")
            type.setTitle(types[row], for: .normal)
            selectedType = row
        case 2:
            NSLog("colors")
            color.setTitle(colors[row], for: .normal)
            selectedColor = colors[row]
        default:
            return NSLog("none")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
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
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @IBAction func optionClick(_ sender: UIButton) {
        self.view.endEditing(true)
        switch sender {
        case brand:
            selected = 0
            picker.reloadAllComponents()
            picker.selectRow(0, inComponent: 0, animated: true)
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
        picker.isHidden = false
    }
    
    @IBAction func sendEdit(_ sender: AnyObject) {
        car.plates = plates.text!
        car.color = selectedColor
        car.type = String(selectedType + 1)
        car.brand = selectedBrand
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "loading") as! LoadingController
        nextViewController.car = car
        nextViewController.selectedIndex = selectedCarIndex
        nextViewController.action = LoadingController.EDIT_CAR
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func clickedCancel(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }

}
