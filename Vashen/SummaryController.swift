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
    
    var clickedAlertOK = false
    
    override func viewDidLoad() {
        initValues()
        initView()
    }
    
    func initValues(){
        token = AppData.readToken()
        activeService = DataBase.getActiveService()
    }
    
    func initView(){
            let format = DateFormatter()
            format.dateFormat = "yyy-MM-dd HH:mm:ss"
            format.locale = Locale(identifier: "us")
            date.text = format.string(from: activeService.acceptedTime!)
            price.text = "$\(activeService.price!)"
            DispatchQueue.global().async {
                self.setMapImage()
            }
        DispatchQueue.global().async {
            self.setCleanerImage()
        }
    }
    
    
    func setMapImage(){
        let urlString = "https://maps.googleapis.com/maps/api/staticmap?center=\(activeService.latitud!),\(activeService.longitud!)&markers=color:red%7Clabel:S%7C\(activeService.latitud!),\(activeService.longitud!)&zoom=14&size=100x100&key="
        let url = NSURL(string: urlString)
        if let data = NSData(contentsOf: url! as URL){
                self.location.image = UIImage(data: data as Data)
        }
    }
    
    func setCleanerImage(){
        let urlString = "http://imanio.zone/Vashen/images/cleaners/" + activeService.cleanerId! + "/profile_image.jpg"
        let url = NSURL(string: urlString)
        if let data = NSData(contentsOf: url! as URL){
                self.cleaner.image = UIImage(data: data as Data)
        }
    }
    @IBAction func clickSend(_ sender: UIButton) {
        DispatchQueue.global(qos: .background).async {
            self.sendReview()
        }
    }
    
    func sendReview() {
        do{
            try Service.sendReview(idService: (activeService?.id)!,rating: rating, withToken: token)
            let services = DataBase.readServices()
            let index = services?.index(where: {$0.id == activeService?.id})
            services![index!].rating = rating
            DataBase.saveServices(services: services!)
            DispatchQueue.main.async {
                _ = self.navigationController?.popViewController(animated: true)
            }
        } catch Service.ServiceError.noSessionFound{
            createAlertInfo(message: "Error con sesion")
            while !clickedAlertOK {
                
            }
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "main") as! SWRevealViewController
            self.present(nextViewController, animated: true, completion: nil)
        } catch {
            createAlertInfo(message: "Error enviando la calificacion")
        }
    }
    
    func createAlertInfo(message:String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {action in
                self.clickedAlertOK = true
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func starClicked(_ sender: UIButton) {
        switch sender {
        case first:
            first.setImage(UIImage(named: "ratingSelected"), for: .normal)
            second.setImage(UIImage(named: "ratingEmpty"), for: .normal)
            third.setImage(UIImage(named: "ratingEmpty"), for: .normal)
            fourth.setImage(UIImage(named: "ratingEmpty"), for: .normal)
            fifth.setImage(UIImage(named: "ratingEmpty"), for: .normal)
            rating = 1
            break
        case second:
            first.setImage(UIImage(named: "ratingSelected"), for: .normal)
            second.setImage(UIImage(named: "ratingSelected"), for: .normal)
            third.setImage(UIImage(named: "ratingEmpty"), for: .normal)
            fourth.setImage(UIImage(named: "ratingEmpty"), for: .normal)
            fifth.setImage(UIImage(named: "ratingEmpty"), for: .normal)
            rating = 2
            break
        case third:
            first.setImage(UIImage(named: "ratingSelected"), for: .normal)
            second.setImage(UIImage(named: "ratingSelected"), for: .normal)
            third.setImage(UIImage(named: "ratingSelected"), for: .normal)
            fourth.setImage(UIImage(named: "ratingEmpty"), for: .normal)
            fifth.setImage(UIImage(named: "ratingEmpty"), for: .normal)
            rating = 3
            break
        case fourth:
            first.setImage(UIImage(named: "ratingSelected"), for: .normal)
            second.setImage(UIImage(named: "ratingSelected"), for: .normal)
            third.setImage(UIImage(named: "ratingSelected"), for: .normal)
            fourth.setImage(UIImage(named: "ratingSelected"), for: .normal)
            fifth.setImage(UIImage(named: "ratingEmpty"), for: .normal)
            rating = 4
            break
        case fifth:
            first.setImage(UIImage(named: "ratingSelected"), for: .normal)
            second.setImage(UIImage(named: "ratingSelected"), for: .normal)
            third.setImage(UIImage(named: "ratingSelected"), for: .normal)
            fourth.setImage(UIImage(named: "ratingSelected"), for: .normal)
            fifth.setImage(UIImage(named: "ratingSelected"), for: .normal)
            rating = 5
            break
        default:
            break
        }
        
    }
    
}
