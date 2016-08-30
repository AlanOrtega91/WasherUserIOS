//
//  InformationController.swift
//  Vashen
//
//  Created by Alan on 8/29/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation

class InformationController: UIViewController {

    @IBOutlet weak var cleanerImage: UIImageView!
    @IBOutlet weak var cleanerName: UILabel!
    var service:Service!
    
    override func viewDidLoad() {
        service = DataBase.getActiveService()
        cleanerName.text = service?.cleanerName
        setImageDrawableForActiveService()
    }
    
    @IBAction func onClickBack(sender: AnyObject) {
        let nextViewController = self.storyboard!.instantiateViewControllerWithIdentifier("reveal_controller") as! SWRevealViewController
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }
    
    func setImageDrawableForActiveService(){
        let url = NSURL(string: "http://imanio.zone/Vashen/images/cleaners/" + service.cleanerId + "/profile_image.jpg")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let data = NSData(contentsOfURL: url!){
                dispatch_async(dispatch_get_main_queue(), {
                    self.cleanerImage.image = UIImage(data: data)
                });
            }
        }
    }
}
