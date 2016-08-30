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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let format = NSDateFormatter()
        format.dateFormat = "yyy-MM-dd HH:mm:ss"
        date.text = format.stringFromDate(activeService.startedTime)
        price.text = " $" + activeService.price
        type.text = activeService.service
        setCleanerImage()
        setMapImage(map,withService: activeService)
    }
    
    func setCleanerImage(){
        let url = NSURL(string: "http://imanio.zone/Vashen/images/cleaners/\(activeService.cleanerId)/profile_image.jpg")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let data = NSData(contentsOfURL: url!){
                dispatch_async(dispatch_get_main_queue(), {
                    self.cleanerImage.image = UIImage(data: data)
                });
            }
        }
    }
    
    func setMapImage(map:UIImageView, withService service:Service){
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/staticmap?center=\(service.latitud),\(service.longitud)&markers=color:red%7Clabel:S%7C\(service.latitud),\(service.longitud)&zoom=15&size=1000x400&key=")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let data = NSData(contentsOfURL: url!){
                dispatch_async(dispatch_get_main_queue(), {
                    self.map.image = UIImage(data: data)
                });
            }
        }
    }
    
    @IBAction func clickedOption(sender: AnyObject) {
        let email = "help@bvashen.com"
        let url = NSURL(string: "mailto:\(email)?subject:Help")
        UIApplication.sharedApplication().openURL(url!)
    }
    @IBAction func clickedCancel(sender: AnyObject) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Map", bundle:nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("reveal_controller") as! SWRevealViewController
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }

}
