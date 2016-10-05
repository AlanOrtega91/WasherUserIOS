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
    
    var brands: [String] = [
        "Acura",
        "Alfa Romeo",
        "Aston Martin",
        "Audi",
        "BAIC",
        "Bentley",
        "BMW",
        "Buick",
        "Cadillac",
        "Chevrolet",
        "Chrysler",
        "Dodge",
        "Ferrari",
        "Fiat",
        "Ford",
        "GMC",
        "Honda",
        "Hyundai",
        "Infiniti",
        "Jaguar",
        "Jeep",
        "Kia",
        "Lamborghini",
        "Land Rover",
        "Lincoln",
        "Maserati",
        "Mazda",
        "McLaren Automotive",
        "Mercedes Benz",
        "MINI",
        "Mitsubishi",
        "Nissan",
        "Peugeot",
        "Porsche",
        "RAM",
        "Renault",
        "SEAT",
        "Smart",
        "Subaru",
        "Suzuki",
        "Tesla",
        "Toyota",
        "Volkswagen",
        "Volvo"]
    var types: [String] = [
        "Moto",
        "Coche Chico",
        "Coche Grande",
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
    
    //TODO: ocultar teclado onclick de botones
    override func viewDidLoad() {
        super.viewDidLoad()
        token = AppData.readToken()
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
            brand.setTitle(brands[row], for: .normal)
            selectedBrand = brands[row]
        case 1:
            type.setTitle(types[row], for: .normal)
            selectedType = row
        case 2:
            color.setTitle(colors[row], for: .normal)
            selectedColor = colors[row]
        default:
            return
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
    
    
    @IBAction func saveNewCar(_ sender: AnyObject) {
        let car = Car()
        car.plates = plates.text
        car.model = "Car"
        car.color = selectedColor
        car.type = String(selectedType + 1)
        car.brand = selectedBrand
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "loading") as! LoadingController
        nextViewController.car = car
        nextViewController.action = LoadingController.NEW_CAR
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func clickedCancel(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }

}
