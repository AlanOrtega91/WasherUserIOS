//
//  HelpController.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation

class HelpController: UIViewController {
    
    var services: Array<Service> = Array<Service>()
    var activeService: Service!
    var idClient: String!
    
    @IBOutlet weak var cleanerImage: UIImageView!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var map: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewWillAppear(_ animated: Bool) {
        initValues()
        initView()
    }
    
    func initValues(){
        idClient = AppData.readUserId()
        services = DataBase.getFinishedServices()
    }
    
    func initView(){
        scrollView.contentSize.height = 800
        if services.count < 1 {
            return
        }
        activeService = services[0]
        let format = DateFormatter()
        format.dateFormat = "yyy-MM-dd HH:mm:ss"
        format.locale = Locale(identifier: "us")
        date.text = format.string(from: activeService.startedTime)
        price.text = " $" + activeService.price
        type.text = activeService.service
        setCleanerImage()
        setMapImage(map: map,withService: activeService)
    }
    
    func setCleanerImage(){
        let url = URL(string: "http://imanio.zone/Vashen/images/cleaners/" + activeService.cleanerId + "/profile_image.jpg")! as URL
        do {
            let data = try Data(contentsOf: url)
            self.cleanerImage.image = UIImage(data: data)
        } catch {}
    }
    
    func setMapImage(map:UIImageView, withService service:Service){
        let urlString = "https://maps.googleapis.com/maps/api/staticmap?center=\(service.latitud!),\(service.longitud!)&markers=color:red%7Clabel:S%7C\(service.latitud!),\(service.longitud!)&zoom=15&size=1000x400&key="
        let url = URL(string: urlString)! as URL
        do {
            let data = try Data(contentsOf: url)
            self.map.image = UIImage(data: data)
        } catch {}
    }
    
    @IBAction func clickedOption(_ sender: AnyObject) {
        let email = "help@bvashen.com"
        let url = NSURL(string: "mailto:\(email)?subject:Help")
        UIApplication.shared.openURL(url! as URL)
    }
    @IBAction func clickedCancel(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }

}
