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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initValues()
        self.tableView.delegate = self
        self.tableView.dataSource = self

    }
    
    override func viewDidAppear(animated: Bool) {

    }
    
    func initValues() {
        cars = DataBase.readCars()
        selectedCar = DataBase.getFavoriteCar()
        token = AppData.readToken()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row >= cars.count {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("addCell")
            return cell!
        } else {
            let car = self.cars[indexPath.row]
            let cell = self.tableView.dequeueReusableCellWithIdentifier("carCell") as! CarCell
            cell.plates.text = car.plates
            cell.brand.text = car.brand
            if selectedCar != nil {
                if selectedCar.id == car.id {
                    cell.selectedIndicator.hidden = false
                } else {
                    cell.selectedIndicator.hidden = true
                }
            } else {
                cell.selectedIndicator.hidden = true
            }
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row >= cars.count {
            return 50
        } else {
            return 90
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row >= cars.count {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Menu", bundle:nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("addCar") as! AddCarController
            self.presentViewController(nextViewController, animated:true, completion:nil)
        } else {
            if isEditingCar {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Menu", bundle:nil)
                let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("editCar") as! EditCarController
                nextViewController.car = cars[indexPath.row]
                self.presentViewController(nextViewController, animated:true, completion:nil)
            } else {
                selectedCar = cars[indexPath.row]
                sendSelectFavCar()
            }
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row >= cars.count {
            return false
        } else {
            return true
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                // do some task
                self.deleteCar(indexPath.row)
            });
        }
    }
    
    func deleteCar(index:Int){
        do{
            let id = cars[index].id
            try Car.deleteFavoriteCar(id, token: token)
            cars.removeAtIndex(index)
            if cars.count == 1 {
                try Car.selectFavoriteCar(cars[0].id, withToken: token)
                cars[0].favorite = 1
            }
            DataBase.saveCars(cars)
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            });
            
        } catch{
            //TODO:implement error
        }
    }
    
    func sendSelectFavCar(){
        do{
            try Car.selectFavoriteCar(selectedCar.id, withToken: token)
            DataBase.setFavoriteCar(selectedCar.id)
            cars = DataBase.readCars()
            tableView.reloadData()
        } catch{
            
        }
    }
    @IBAction func onClickEdit(sender: AnyObject) {
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
    
    @IBAction func clickedCancel(sender: AnyObject) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Map", bundle:nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("reveal_controller") as! SWRevealViewController
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }

}
