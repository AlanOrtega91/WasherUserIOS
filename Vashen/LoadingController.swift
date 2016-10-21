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
import AVFoundation

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
    //TODO: change to Conekta
    var tokenConekta:Token!
    //EditCar
    var selectedIndex:Int!
    //NewCar
    var car:Car!
    //Edit Account
    var user:User!
    var clickedAlertOK = false
    
    @IBOutlet var videoView: UIView!

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.animateView()
        DispatchQueue.global(qos: .background).async {
            self.initValues()
        }
    }
    
    func animateView()
    {
        
        let path = URL(fileURLWithPath: Bundle.main.path(forResource: "Splash", ofType: "mov")!)
        let player = AVPlayer(url: path)
        let newLayer = AVPlayerLayer(player: player)
        newLayer.frame = self.videoView.frame
        self.videoView.layer.addSublayer(newLayer)
        newLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        player.play()
        
        
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
            DispatchQueue.main.async {
                _ = self.navigationController?.popViewController(animated: true)
            }
            break
        }
    }
    
    func tryLogin(){
        do {
            try ProfileReader.run(email: email, withPassword:password)
            token = AppData.readToken()
            if let firebaseToken = FIRInstanceID.instanceID().token() {
                try User.saveFirebaseToken(token: token,pushNotificationToken: firebaseToken)
            }
            //TODO: new stack
            let storyBoard = UIStoryboard(name: "Map", bundle: nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "reveal_controller")
            DispatchQueue.main.async {
                self.navigationController?.setViewControllers([nextViewController], animated: true)
                _ = self.navigationController?.popToRootViewController(animated: true)
            }
        }  catch User.UserError.errorSavingFireBaseToken{
            createAlertInfo(message: "Error con el sistema de notificaciones")
            while !clickedAlertOK {
                
            }
            DispatchQueue.main.async {
                _ = self.navigationController?.popViewController(animated: true)
            }
        } catch {
            createAlertInfo(message: "Error al iniciar sesion")
            while !clickedAlertOK {
                
            }
            DispatchQueue.main.async {
                _ = self.navigationController?.popViewController(animated: true)
            }
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
            user = try User.sendNewUser(user: user, withPassword: self.password)
            AppData.saveData(user: user)
            DataBase.saveUser(user: user)
            if let fireBaseToken = FIRInstanceID.instanceID().token() {
                try User.saveFirebaseToken(token: user.token, pushNotificationToken: fireBaseToken)
            }
            
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "createPayment") as! CreateAccountPaymentController
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
        } catch {
            createAlertInfo(message: "Error al crear usuario")
            while !clickedAlertOK {
                
            }
            DispatchQueue.main.async {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func tryNewCard(){
        //TODO: change to Conekta
        tokenConekta?.create(success: { (data) -> Void in
            print(data)
            if data?["object"] as! String == "error" {
                let stackSize = self.navigationController?.viewControllers.count
                let destinationVC = self.navigationController?.viewControllers[stackSize! - 2]
                DispatchQueue.main.async {
                    _ = self.navigationController?.popToViewController(destinationVC!, animated: true)
                }
                return
            }
            do {
                let cardToken = data?["id"] as! String
                try UserCard.saveNewCardToken(token: self.token, withCard: cardToken)
                try ProfileReader.run()
                let stackSize = self.navigationController?.viewControllers.count
                let destinationVC = self.navigationController?.viewControllers[stackSize! - 3]
                DispatchQueue.main.async {
                    _ = self.navigationController?.popToViewController(destinationVC!, animated: true)
                }
            } catch {
                print("Error reading credit card on create payment")
                let stackSize = self.navigationController?.viewControllers.count
                let destinationVC = self.navigationController?.viewControllers[stackSize! - 2]
                DispatchQueue.main.async {
                    _ = self.navigationController?.popToViewController(destinationVC!, animated: true)
                }
            }
            }, andError: { (error) -> Void in
                print(error)
                let stackSize = self.navigationController?.viewControllers.count
                let destinationVC = self.navigationController?.viewControllers[stackSize! - 2]
                DispatchQueue.main.async {
                    _ = self.navigationController?.popToViewController(destinationVC!, animated: true)
                }
        })
    }
    
    func tryNewCar(){
        do {
            var cars = DataBase.readCars()
            car.id = try Car.addNewFavoriteCar(car: car,withToken: token)
            if cars.count == 0 {
                try Car.selectFavoriteCar(carId: car.id,withToken: token)
                car.favorite = 1
            }
            cars.append(car)
            DataBase.saveCars(cars: cars)
            let stackSize = self.navigationController?.viewControllers.count
            let destinationVC = self.navigationController?.viewControllers[stackSize! - 3]
            DispatchQueue.main.async {
                _ = self.navigationController?.popToViewController(destinationVC!, animated: true)
            }
        } catch Car.CarError.noSessionFound{
            createAlertInfo(message: "Error con la sesion")
            while !clickedAlertOK {
                
            }
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "main")
            DispatchQueue.main.async {
                self.navigationController?.setViewControllers([nextViewController], animated: true)
                _ = self.navigationController?.popToRootViewController(animated: true)
            }
        } catch {
            createAlertInfo(message: "Error al agregar coche")
            while !clickedAlertOK {
                
            }
            DispatchQueue.main.async {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func tryEditCar(){
        do {
            var cars = DataBase.readCars()
            cars[selectedIndex] = car
            try Car.editFavoriteCar(car: car,withToken: token)
            DataBase.saveCars(cars: cars)
            
            let stackSize = self.navigationController?.viewControllers.count
            let destinationVC = self.navigationController?.viewControllers[stackSize! - 3]
            DispatchQueue.main.async {
                _ = self.navigationController?.popToViewController(destinationVC!, animated: true)
            }
        }  catch Car.CarError.noSessionFound{
            createAlertInfo(message: "Error con la sesion")
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "main")
            self.navigationController?.setViewControllers([nextViewController], animated: true)
            DispatchQueue.main.async {
                _ = self.navigationController?.popToRootViewController(animated: true)
            }
        } catch {
            DispatchQueue.main.async {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func tryEditAccount(){
        do {
            try user.sendChangeUserData(token: token)
            DataBase.saveUser(user: user)
            
            let stackSize = self.navigationController?.viewControllers.count
            let destinationVC = self.navigationController?.viewControllers[stackSize! - 3]
            DispatchQueue.main.async {
                _ = self.navigationController?.popToViewController(destinationVC!, animated: true)
            }
        }  catch Car.CarError.noSessionFound{
            createAlertInfo(message: "Error con la sesion")
            while !clickedAlertOK {
                
            }
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "main")
            self.navigationController?.setViewControllers([nextViewController], animated: true)
            DispatchQueue.main.async {
                _ = self.navigationController?.popToRootViewController(animated: true)
            }
        } catch {
            createAlertInfo(message: "Error editar los datos")
            while !clickedAlertOK {
                
            }
            DispatchQueue.main.async {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    func createAlertInfo(message:String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {action in
            self.clickedAlertOK = true
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    enum LoginError: Error {
        case error
    }
}
