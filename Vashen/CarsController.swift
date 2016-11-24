//
//  CarsController.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation

class CarsController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    
    var idClient: String!
    var token: String!
    var cars: Array<Car> = Array<Car>()
    var selectedCar: Car!
    var isEditingCar = false
    var clickedAlertOK = false
    
    override func viewDidLoad() {
        initValues()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.setEditing(false, animated: true)
        self.tableView.setEditing(false, animated: true)
        isEditingCar = false
        rightBarButton.title = "Editar"
        initValues()
        self.tableView.reloadData()
    }
    
    func initValues() {
        cars = DataBase.readCars()
        selectedCar = DataBase.getFavoriteCar()
        token = AppData.readToken()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= cars.count {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "addCell")
            return cell!
        } else {
            let car = self.cars[indexPath.row]
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "carCell") as! CarCell
            cell.plates.text = car.plates
            cell.brand.text = car.brand
            if selectedCar != nil {
                if selectedCar.id == car.id {
                    cell.selectedIndicator.isHidden = false
                } else {
                    cell.selectedIndicator.isHidden = true
                }
            } else {
                cell.selectedIndicator.isHidden = true
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row >= cars.count {
            return 50
        } else {
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= cars.count {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Menu", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "addCar") as! AddCarController
            self.navigationController?.pushViewController(nextViewController, animated: true)
        } else {
            if isEditingCar {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Menu", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "editCar") as! EditCarController
                nextViewController.car = cars[indexPath.row]
                self.navigationController?.pushViewController(nextViewController, animated: true)
            } else {
                selectedCar = cars[indexPath.row]
                sendSelectFavCar()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row >= cars.count {
            return false
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteCar(index: indexPath.row)
        }
    }
    
    func deleteCar(index:Int){
        do{
            let id = cars[index].id
            try Car.deleteFavoriteCar(id: id!, token: token)
            cars.remove(at: index)
            if cars.count == 1 {
                try Car.selectFavoriteCar(carId: cars[0].id, withToken: token)
                cars[0].favorite = 1
            }
            DataBase.saveCars(cars: cars)
            self.tableView.reloadData()
            
        } catch Car.CarError.errorDeletingCar{
            createAlertInfo(message: "Error borrando coche");
        } catch Car.CarError.errorAddingFavoriteCar{
            createAlertInfo(message: "Error al seleccionar coche favorito")
            self.viewDidLoad()
        } catch Car.CarError.noSessionFound {
            createAlertInfo(message: "Error de sesion")
            while !clickedAlertOK {
                
            }
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "main")
            self.navigationController?.setViewControllers([nextViewController], animated: true)
            _ = self.navigationController?.popToRootViewController(animated: true)
        } catch {}
    }
    
    func createAlertInfo(message:String){
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {action in
                self.clickedAlertOK = true
            }))
            self.present(alert, animated: true, completion: nil)
    }
    
    func sendSelectFavCar(){
        do{
            try Car.selectFavoriteCar(carId: selectedCar.id, withToken: token)
            DataBase.setFavoriteCar(id: selectedCar.id)
            cars = DataBase.readCars()
            tableView.reloadData()
        } catch Car.CarError.noSessionFound{
            createAlertInfo(message: "Error de sesion")
            while !clickedAlertOK {
                
            }
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "main")
            self.navigationController?.setViewControllers([nextViewController], animated: true)
            _ = self.navigationController?.popToRootViewController(animated: true)
        } catch {
            createAlertInfo(message: "Error al seleccionar coche favorito")
        }
    }
    @IBAction func onClickEdit(_ sender: AnyObject) {
        if isEditingCar {
            super.setEditing(false, animated: true)
            self.tableView.setEditing(false, animated: true)
            isEditingCar = false
            rightBarButton.title = "Editar"
        } else {
            super.setEditing(true, animated: true)
            self.tableView.setEditing(true, animated: true)
            isEditingCar = true
            rightBarButton.title = "Listo"
        }
    }
    
    @IBAction func clickedCancel(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }

}
