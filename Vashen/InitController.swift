//
//  InitController.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging

class InitController: UIViewController {
    
    var settings : NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var token : String = ""
    var clickedAlertOK = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func initValues() {
        token = AppData.readToken()
    }
    
    func initView() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.decideNextView()
        });
    }
    
    func decideNextView(){
        if token == "" {
            changeView("Main", controllerName: "main")
        } else{
            tryReadUser()
        }
    }
    
    func tryReadUser() {
        do{
            try ProfileReader.run()
            getPaymentToken()
            
            
            let firebaseToken = FIRInstanceID.instanceID().token()
            if firebaseToken == nil {
                throw User.UserError.errorSavingFireBaseToken
            } else {
                try User.saveFirebaseToken(token,pushNotificationToken: firebaseToken!)
            }
            changeView("Map", controllerName: "reveal_controller")
        } catch User.UserError.errorSavingFireBaseToken{
            ProfileReader.delete()
            createAlertInfo("Error con el sistema de notificaciones")
            while !clickedAlertOK {
                
            }
            changeView("Main", controllerName: "main")
        } catch {
            ProfileReader.delete()
            createAlertInfo("Error con el inicio de sesion")
            while !clickedAlertOK {
                
            }
            changeView("Main", controllerName: "main")
        }
    }
    
    private func getPaymentToken(){
        do{
           let paymentToken = try Payment.getPaymentToken(token)
            AppData.savePaymentToken(paymentToken)
            
        } catch Payment.PaymentError.errorGettingPaymentToken{
            createAlertInfo("Pagos no disponibles")
        } catch Payment.PaymentError.noSessionFound{
            createAlertInfo("Error con sesion")
            changeView("Main", controllerName: "main")
        } catch {
            createAlertInfo("Error general")
            changeView("Main", controllerName: "main")
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
    
    override func viewDidAppear(animated: Bool) {
        initValues()
        initView()
    }
}
