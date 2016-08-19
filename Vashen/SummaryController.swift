//
//  SummaryController.swift
//  Vashen
//
//  Created by Alan on 8/18/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation

class SummaryController: UIViewController {

    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var cleaner: UIImageView!
    @IBOutlet weak var location: UIImageView!
    
    @IBOutlet weak var first: UIButton!
    @IBOutlet weak var second: UIButton!
    @IBOutlet weak var third: UIButton!
    @IBOutlet weak var fourth: UIButton!
    @IBOutlet weak var fifth: UIButton!

    var rating = 0
    var token:String!
    var activeService:Service!
    
    override func viewDidAppear(animated: Bool) {
        initValues()
        initView()
    }
    
    func initValues(){
        token = AppData.readToken()
        activeService = DataBase.getActiveService()
        if activeService == nil {
            //TODO: go back to revealViewcontroller
        }
    }
    
    func initView(){
        if activeService != nil {
            let format = NSDateFormatter()
            format.dateFormat = "yyy-MM-dd HH:mm:ss"
            date.text = format.stringFromDate(activeService.acceptedTime)
            price.text = activeService.price
            NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(setMapImage), userInfo: nil, repeats: false)
            NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: #selector(setCleanerImage), userInfo: nil, repeats: false)
        }
    }
    
    func setMapImage(){
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/staticmap?center=\(activeService.latitud),\(activeService.longitud)&markers=color:red%7Clabel:S%7C\(activeService.latitud),\(activeService.longitud)&zoom=15&size=1000x400&key=")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let data = NSData(contentsOfURL: url!){
                dispatch_async(dispatch_get_main_queue(), {
                    self.location.image = UIImage(data: data)
                });
            }
        }
    }
    
    func setCleanerImage(){
        let url = NSURL(string: "http://imanio.zone/Vashen/images/cleaners/" + activeService.id + "/profile_image.jpg")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let data = NSData(contentsOfURL: url!){
                dispatch_async(dispatch_get_main_queue(), {
                    self.cleaner.image = UIImage(data: data)
                });
            }
        }
    }
    @IBAction func clickSend(sender: UIButton) {
        NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: #selector(sendReview), userInfo: nil, repeats: false)
    }
    
    func sendReview() {
        do{
            try Service.sendReview(activeService.id,rating: rating, withToken: token)
            let services = DataBase.readServices()
            let index = services?.indexOf({$0.id == activeService.id})
            services![index!].rating = rating
            DataBase.saveServices(services!)
            
            let storyBoard = UIStoryboard(name: "Map", bundle: nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("reveal_controller") as! SWRevealViewController
            self.presentViewController(nextViewController, animated: true, completion: nil)
        } catch {
            //TODO: implement errors
        }
    }
    
    @IBAction func starClicked(sender: UIButton) {
        switch sender {
        case first:
            first.setImage(UIImage(named: "selectedImage"), forState: .Normal)
            second.setImage(UIImage(named: "rating"), forState: .Normal)
            third.setImage(UIImage(named: "rating"), forState: .Normal)
            fourth.setImage(UIImage(named: "rating"), forState: .Normal)
            fifth.setImage(UIImage(named: "rating"), forState: .Normal)
            rating = 1
            break
        case second:
            first.setImage(UIImage(named: "selectedImage"), forState: .Normal)
            second.setImage(UIImage(named: "selectedImage"), forState: .Normal)
            third.setImage(UIImage(named: "rating"), forState: .Normal)
            fourth.setImage(UIImage(named: "rating"), forState: .Normal)
            fifth.setImage(UIImage(named: "rating"), forState: .Normal)
            rating = 2
            break
        case third:
            first.setImage(UIImage(named: "selectedImage"), forState: .Normal)
            second.setImage(UIImage(named: "selectedImage"), forState: .Normal)
            third.setImage(UIImage(named: "selectedImage"), forState: .Normal)
            fourth.setImage(UIImage(named: "rating"), forState: .Normal)
            fifth.setImage(UIImage(named: "rating"), forState: .Normal)
            rating = 3
            break
        case fourth:
            first.setImage(UIImage(named: "selectedImage"), forState: .Normal)
            second.setImage(UIImage(named: "selectedImage"), forState: .Normal)
            third.setImage(UIImage(named: "selectedImage"), forState: .Normal)
            fourth.setImage(UIImage(named: "selectedImage"), forState: .Normal)
            fifth.setImage(UIImage(named: "rating"), forState: .Normal)
            rating = 4
            break
        case fifth:
            first.setImage(UIImage(named: "selectedImage"), forState: .Normal)
            second.setImage(UIImage(named: "selectedImage"), forState: .Normal)
            third.setImage(UIImage(named: "selectedImage"), forState: .Normal)
            fourth.setImage(UIImage(named: "selectedImage"), forState: .Normal)
            fifth.setImage(UIImage(named: "selectedImage"), forState: .Normal)
            rating = 5
            break
        default:
            break
        }
        
    }
    
}
