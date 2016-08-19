//
//  LoadingController.swift
//  Vashen
//
//  Created by Alan on 8/3/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation
import Firebase
import FirebaseMessaging

public class LoadingController: UIViewController {
    public static let LOGIN: Int = 10
    public static let REGISTER: Int = 20
    public static let NEW_CARD: Int = 30
    public static let NEW_CAR: Int = 40
    public static let EDIT_CAR: Int = 50
    public static let EDIT_ACCOUNT: Int = 60
    var action: Int = 0
    var token:String!
    //REGISTER AND LOGIN
    var name: String!
    var lastName:String!
    var phone:String!
    var encodedImage:String!
    var email: String!
    var password: String!
    var fireBaseToken:String = FIRInstanceID.instanceID().token()!
    var image: UIImage!
    //NewCard
    //var braintreeFragment:BraintreeFragment!
    //var card:CardBuilder!
    //EditCar
    var selectedIndex:Int!
    //NewCar
    var car:Car!
    //Edit Account
    var user:User!
    
    override public func viewDidAppear(animated: Bool) {
        initView()
        initValues()
    }
    
    func initValues(){
        token = AppData.readToken()
        switch action {
        case LoadingController.LOGIN:
            tryLogin()
            break;
        case LoadingController.REGISTER:
            tryRegister()
            break;
        case LoadingController.NEW_CARD:
            tryNewCard()
            break;
        case LoadingController.NEW_CAR:
            tryNewCar()
            break;
        case LoadingController.EDIT_CAR:
            tryEditCar()
            break;
        case LoadingController.EDIT_ACCOUNT:
            tryEditAccount()
            break;
        default:
            let nextViewController = self.storyboard!.instantiateViewControllerWithIdentifier("main") as! MainController
            self.presentViewController(nextViewController, animated: true, completion: nil)
            break
        }
    }
    
    func tryLogin(){
        do {
        try ProfileReader.run(email, withPassword:password)
            token = AppData.readToken()
            try getPaymentToken()
            //TODO: implement this AppData.readFirebaseToken()
            FIRMessaging.messaging().connectWithCompletion({ (error) in
                if (error != nil){
                    print("Unable to connect with FCM = \(error)")
                } else {
                    print("Connected to FCM")
                }
            })
            try User.saveFirebaseToken(token,pushNotificationToken: fireBaseToken)
            let storyBoard = UIStoryboard(name: "Map", bundle: nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("reveal_controller") as! SWRevealViewController
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
        } catch {
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let nextViewController = storyboard.instantiateViewControllerWithIdentifier("login") as! LoginController
            nextViewController.emailSet = email
            nextViewController.passwordSet = password
            self.presentViewController(nextViewController, animated: true, completion: nil)
        }
    }
    
    func tryRegister(){
        do {
            var user = User()
            user.name = self.name
            user.lastName = self.lastName
            user.email = self.email
            user.phone = self.phone
            user.encodedImage = self.encodedImage
            user = try User.sendNewUser(user, withPassword: self.password)
            AppData.saveData(user)
            try DataBase.saveUser(user)
            try User.saveFirebaseToken(user.token, pushNotificationToken: self.fireBaseToken)
            
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("createPayment") as! SWRevealViewController
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
        } catch {
            //TODO:change to create personal
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let nextViewController = storyboard.instantiateViewControllerWithIdentifier("createPersonal") as! CreateAccountPersonalController
            nextViewController.name.text = name
            nextViewController.lastName.text = lastName
            nextViewController.email = email
            nextViewController.phone = phone
            nextViewController.password = password
            nextViewController.image.image = image
            self.presentViewController(nextViewController, animated: true, completion: nil)
        }
    }
    
    func tryNewCard(){
        do {
    
            let storyBoard = UIStoryboard(name: "Map", bundle: nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("reveal_controller") as! SWRevealViewController
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
        } catch {
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let nextViewController = storyboard.instantiateViewControllerWithIdentifier("login") as! LoginController
            nextViewController.emailSet = email
            nextViewController.passwordSet = password
            self.presentViewController(nextViewController, animated: true, completion: nil)
        }
    }
    
    func tryNewCar(){
        do {
            var cars = DataBase.readCars()
            car.id = try Car.addNewFavoriteCar(car,withToken: token)
            if cars.count == 0 {
                try Car.selectFavoriteCar(car.id,withToken: token)
                car.favorite = 1
            }
            cars.append(car)
            try DataBase.saveCars(cars)
            let storyBoard = UIStoryboard(name: "Menu", bundle: nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("cars") as! CarsController
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
        } catch {
            let storyboard = UIStoryboard.init(name: "Menu", bundle: nil)
            let nextViewController = storyboard.instantiateViewControllerWithIdentifier("addCar") as! AddCarController
            self.presentViewController(nextViewController, animated: true, completion: nil)
        }
    }
    
    func tryEditCar(){
        do {
            var cars = DataBase.readCars()
            cars[selectedIndex] = car
            try Car.editFavoriteCar(car,withToken: token)
            try DataBase.saveCars(cars)
            
            let storyBoard = UIStoryboard(name: "Menu", bundle: nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("cars") as! CarsController
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
        } catch {
            let storyboard = UIStoryboard.init(name: "Menu", bundle: nil)
            let nextViewController = storyboard.instantiateViewControllerWithIdentifier("editCar") as! EditCarController
 
            self.presentViewController(nextViewController, animated: true, completion: nil)
        }
    }
    
    func tryEditAccount(){
        do {
            try user.sendChangeUserData(token)
            try DataBase.saveUser(user)

            //TODO: Check from billing or config
            let storyBoard = UIStoryboard(name: "Menu", bundle: nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("billing") as! EditBillingController
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
        } catch {
            let storyboard = UIStoryboard.init(name: "Menu", bundle: nil)
            let nextViewController = storyboard.instantiateViewControllerWithIdentifier("editBilling") as! EditBillingController
            self.presentViewController(nextViewController, animated: true, completion: nil)
        }
    }
    
    
    private func getPaymentToken() throws{
        do{
            let paymentToken = try Payment.getPaymentToken(token)
            AppData.savePaymentToken(paymentToken)
            
        } catch Payment.PaymentError.errorGettingPaymentToken{
            postAlert("Pagos no disponibles")
            throw LoginError.error
        } catch Payment.PaymentError.noSessionFound{
            postAlert("Error con sesion")
            throw LoginError.error
        } catch {
            postAlert("Error general")
            throw LoginError.error
        }
    }
    
    private func changeView(storyBoardName:String, controllerName:String){
        let storyBoard = UIStoryboard(name: storyBoardName, bundle: nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier(controllerName)
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(nextViewController, animated: true, completion: nil)
        })
        
    }
    
    private func postAlert(message:String){
        let toastLabel = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - 150, self.view.frame.size.height-100, 300, 35))
        toastLabel.backgroundColor = UIColor.blackColor()
        toastLabel.textColor = UIColor.whiteColor()
        toastLabel.textAlignment = NSTextAlignment.Center;
        self.view.addSubview(toastLabel)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        
        UIView.animateWithDuration(4.0,delay: 0.1,options: .CurveEaseOut, animations: {toastLabel.alpha = 0.0}, completion: nil)
    }
    
    func initView()  {
        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.image = UIImage(named: "loading")
        self.view.insertSubview(backgroundImage, atIndex: 0)
    }
    
    enum LoginError: ErrorType {
        case error
    }

}
