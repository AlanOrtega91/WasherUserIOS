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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func initValues() {
        token = AppData.readToken()
    }
    
    func initView() {
        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.image = UIImage(named: "loading")
        self.view.insertSubview(backgroundImage, atIndex: 0)
        let sendDecideNextViewThread:NSThread = NSThread(target: self, selector:#selector(decideNextView), object: nil)
        sendDecideNextViewThread.start()
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
            
            let firebaseToken = FIRInstanceID.instanceID().token()!
            FIRMessaging.messaging().connectWithCompletion({ (error) in
                if (error != nil){
                    print("Unable to connect with FCM = \(error)")
                } else {
                    print("Connected to FCM")
                }
            })
            try User.saveFirebaseToken(token,pushNotificationToken: firebaseToken)

            changeView("Map", controllerName: "reveal_controller")
        } catch User.UserError.errorSavingFireBaseToken{
            postAlert("Error con FB")
            ProfileReader.delete()
            changeView("Main", controllerName: "main")
        } catch {
            let nextViewController = self.storyboard!.instantiateViewControllerWithIdentifier("main") as! MainController
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
        }
    }
    
    private func getPaymentToken(){
        do{
           let paymentToken = try Payment.getPaymentToken(token)
            AppData.savePaymentToken(paymentToken)
            
        } catch Payment.PaymentError.errorGettingPaymentToken{
            postAlert("Pagos no disponibles")
        } catch Payment.PaymentError.noSessionFound{
            postAlert("Error con sesion")
            changeView("Main", controllerName: "main")
        } catch {
            postAlert("Error general")
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        initValues()
        initView()
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
