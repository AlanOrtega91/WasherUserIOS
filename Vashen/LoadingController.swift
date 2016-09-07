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
    var image: UIImage!
    //NewCard
    var braintreeClient:BTAPIClient!
    var card:BTCard!
    //EditCar
    var selectedIndex:Int!
    //NewCar
    var car:Car!
    //Edit Account
    var user:User!
    var clickedAlertOK = false
    
    override public func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // do some task
            self.initValues()
        });
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
//            FIRMessaging.messaging().connectWithCompletion({ (error) in
//                if (error != nil){
//                    print("Unable to connect with FCM = \(error)")
//                } else {
//                    print("Connected to FCM")
//                }
//            })
            if let firebaseToken = FIRInstanceID.instanceID().token() {
                try User.saveFirebaseToken(token,pushNotificationToken: firebaseToken)
            } else {
                throw User.UserError.errorSavingFireBaseToken
            }
            
            let storyBoard = UIStoryboard(name: "Map", bundle: nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("reveal_controller") as! SWRevealViewController
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
        }  catch User.UserError.errorSavingFireBaseToken{
            createAlertInfo("Error con el sistema de notificaciones")
            while !clickedAlertOK {
                
            }
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let nextViewController = storyboard.instantiateViewControllerWithIdentifier("login") as! LoginController
            nextViewController.emailSet = email
            nextViewController.passwordSet = password
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
        } catch {
            createAlertInfo("Error al iniciar sesion")
            while !clickedAlertOK {
                
            }
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let nextViewController = storyboard.instantiateViewControllerWithIdentifier("login") as! LoginController
            nextViewController.emailSet = email
            nextViewController.passwordSet = password
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
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
            DataBase.saveUser(user)
            let fireBaseToken:String = FIRInstanceID.instanceID().token()!
            try User.saveFirebaseToken(user.token, pushNotificationToken: fireBaseToken)
            
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("createPayment") as! CreateAccountPaymentController
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
        } catch {
            createAlertInfo("Error al crear usuario")
            while !clickedAlertOK {
                
            }
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let nextViewController = storyboard.instantiateViewControllerWithIdentifier("createPersonal") as! CreateAccountPersonalController
            nextViewController.name.text = name
            nextViewController.lastName.text = lastName
            nextViewController.email = email
            nextViewController.phone = phone
            nextViewController.password = password
            nextViewController.image.image = image
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
        }
    }
    
    func tryNewCard(){
        let paymentToken = AppData.readPaymentToken()
        braintreeClient = BTAPIClient(authorization: paymentToken)
        
        if let cardClient = BTCardClient(APIClient: braintreeClient) as? BTCardClient{
            cardClient.tokenizeCard(card, completion: {
                (tokenizedCard,error) in
                do {
                    try ProfileReader.run()
                    let storyBoard = UIStoryboard(name: "Map", bundle: nil)
                    let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("reveal_controller") as! SWRevealViewController
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(nextViewController, animated: true, completion: nil)
                    })
                } catch {
                    print("Error reading credit card on create payment")
                    let storyboard = UIStoryboard.init(name: "Map", bundle: nil)
                    let nextViewController = storyboard.instantiateViewControllerWithIdentifier("reveal_controller") as! SWRevealViewController
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(nextViewController, animated: true, completion: nil)
                    })
                }
            })
        } else {
            let storyboard = UIStoryboard.init(name: "Map", bundle: nil)
            let nextViewController = storyboard.instantiateViewControllerWithIdentifier("reveal_controller") as! SWRevealViewController
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
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
            DataBase.saveCars(cars)
            let storyBoard = UIStoryboard(name: "Menu", bundle: nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("cars") as! CarsController
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
        } catch Car.CarError.noSessionFound{
            createAlertInfo("Error con la sesion")
            while !clickedAlertOK {
                
            }
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("main")
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
        } catch {
            createAlertInfo("Error al agregar coche")
            while !clickedAlertOK {
                
            }
            let storyboard = UIStoryboard.init(name: "Menu", bundle: nil)
            let nextViewController = storyboard.instantiateViewControllerWithIdentifier("addCar") as! AddCarController
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
        }
    }
    
    func tryEditCar(){
        do {
            var cars = DataBase.readCars()
            cars[selectedIndex] = car
            try Car.editFavoriteCar(car,withToken: token)
            DataBase.saveCars(cars)
            
            let storyBoard = UIStoryboard(name: "Menu", bundle: nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("cars") as! CarsController
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
        }  catch Car.CarError.noSessionFound{
            createAlertInfo("Error con la sesion")
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("main")
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
        } catch {
            createAlertInfo("Error al editar coche")
            let storyboard = UIStoryboard.init(name: "Menu", bundle: nil)
            let nextViewController = storyboard.instantiateViewControllerWithIdentifier("editCar") as! EditCarController
            nextViewController.car = car
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
        }
    }
    
    func tryEditAccount(){
        do {
            try user.sendChangeUserData(token)
            DataBase.saveUser(user)

            //TODO: Check from billing or config
            let storyBoard = UIStoryboard(name: "Map", bundle: nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("reveal_controller") as! SWRevealViewController
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
        }  catch Car.CarError.noSessionFound{
            createAlertInfo("Error con la sesion")
            while !clickedAlertOK {
                
            }
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("main")
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
        } catch {
            createAlertInfo("Error editar los datos")
            while !clickedAlertOK {
                
            }
            let storyboard = UIStoryboard.init(name: "Map", bundle: nil)
            let nextViewController = storyboard.instantiateViewControllerWithIdentifier("reveal_controller") as! SWRevealViewController
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
        }
    }
    
    
    private func getPaymentToken() throws{
        do{
            let paymentToken = try Payment.getPaymentToken(token)
            AppData.savePaymentToken(paymentToken)
            
        } catch Payment.PaymentError.errorGettingPaymentToken{
            createAlertInfo("Pagos no disponibles")
            throw LoginError.error
        } catch Payment.PaymentError.noSessionFound{
            createAlertInfo("Error con sesion")
            throw LoginError.error
        } catch {
            createAlertInfo("Error general")
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
    
    func createAlertInfo(message:String){
        dispatch_async(dispatch_get_main_queue(), {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {action in
                self.clickedAlertOK = true
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    
    enum LoginError: ErrorType {
        case error
    }

}
