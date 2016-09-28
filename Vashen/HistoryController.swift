//
//  HistoryController.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation

class HistoryController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var idClient:String!
    var services: Array<Service> = Array<Service>()
    
    override func viewWillAppear(_ animated: Bool) {
        initValues()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func initValues() {
        services = DataBase.getFinishedServices()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let service = self.services[indexPath.row]
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "historyCell") as! HistoryRowTableViewCell
        let format = DateFormatter()
        format.dateFormat = "yyy-MM-dd HH:mm:ss"
        format.locale = Locale(identifier: "us")
        cell.date.text = format.string(from: service.acceptedTime)
        cell.serviceType.text = service.service + " $" + service.price
        setCleanerImage(image: cell.cleanerImage, withId: service.cleanerId)
        setMapImage(map: cell.locationImage, withService: service)
        return cell
    }
    
    func setMapImage(map: UIImageView, withService service:Service){
        let urlString = "https://maps.googleapis.com/maps/api/staticmap?center=\(service.latitud!),\(service.longitud!)&markers=color:red%7Clabel:S%7C\(service.latitud!),\(service.longitud!)&zoom=15&size=1000x400&key="
        let url = URL(string: urlString)! as URL
        do {
        let data = try Data(contentsOf: url)
        map.image = UIImage(data: data)
        } catch {}
    }
    
    func setCleanerImage(image:UIImageView, withId id: String){
        let url = URL(string: "http://imanio.zone/Vashen/images/cleaners/" + id + "/profile_image.jpg")! as URL
        do {
            let data = try Data(contentsOf: url)
            image.image = UIImage(data: data)
        } catch {}

    }
    
    
    @IBAction func clickedCancel(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }

}
