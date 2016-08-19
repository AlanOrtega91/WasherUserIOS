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
    
    var idClient: String!
    var token: String!
    var cars: Array<Car> = Array<Car>()
    var selectedCar: Car!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.image = UIImage(named: "background")
        self.view.insertSubview(backgroundImage, atIndex: 0)
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
        return cars.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let car = self.cars[indexPath.row]
        let cell = self.tableView.dequeueReusableCellWithIdentifier("car_cell") as! CarCell
        cell.plates.text = car.plates
        cell.brand.text = car.brand
        if selectedCar.id == car.id {
            cell.selectedIndicator.hidden = false
        } else {
            cell.selectedIndicator.hidden = true
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedCar = cars[indexPath.row]
        sendSelectFavCar()
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
    
    @IBAction func clickedCancel(sender: AnyObject) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Map", bundle:nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("reveal_controller") as! SWRevealViewController
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }

}
