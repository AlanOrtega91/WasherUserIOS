//
//  InformationController.swift
//  Vashen
//
//  Created by Alan on 8/29/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation

class InformationController: UIViewController {

    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var cleanerName: UILabel!
    @IBOutlet weak var cleanerImage: UIImageView!
    
    var service:Service!
    var token:String!
    
    override func viewDidLoad() {
        service = DataBase.getActiveService()
        token = AppData.readToken()
        cleanerName.text = service?.cleanerName
        setImageDrawableForActiveService()
        DispatchQueue.global().async {
            self.readCleanerRating()
        }
    }
    
    @IBAction func onClickBack(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func readCleanerRating(){
        do {
            let rating = try Cleaner.readCleanerRating(cleanerId: service.cleanerId,withToken: token)
            DispatchQueue.main.async {
                self.setCleanerRatingImage(rating: rating)
            }
        } catch {
            
        }
    }
    
    func setCleanerRatingImage(rating:Double) {
        switch rating.rounded() {
        case 0:
            ratingImage.image = UIImage(named: "rating0")
        case 1:
            ratingImage.image = UIImage(named: "rating1")
        case 2:
            ratingImage.image = UIImage(named: "rating2")
        case 3:
            ratingImage.image = UIImage(named: "rating3")
        case 4:
            ratingImage.image = UIImage(named: "rating4")
        case 5:
            ratingImage.image = UIImage(named: "rating5")
        default:
            ratingImage.image = UIImage(named: "rating0")
        }
    }
    
    func setImageDrawableForActiveService(){
        let url = NSURL(string: "http://54.218.50.2/api/1.0.0/images/cleaners/" + service.cleanerId + "/profile_image.jpg")
        do {
            let data:Data = try Data(contentsOf: url! as URL)
            self.cleanerImage.image = UIImage(data: data)
        } catch {}
    }
}
