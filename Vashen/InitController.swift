//
//  InitController.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class InitController: UIViewController {
    
    var settings : UserDefaults = UserDefaults.standard
    var clickedAlertOK = false
    
    @IBOutlet var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.animateView()
        connectToFcm()
        DispatchQueue.global().async {
            self.decideNextView()
        }
    }
    
    func animateView() {
        let path = URL(fileURLWithPath: Bundle.main.path(forResource: "Splash", ofType: "mov")!)
        let player = AVPlayer(url: path)
        let newLayer = AVPlayerLayer(player: player)
        newLayer.frame = self.videoView.frame
        self.videoView.layer.addSublayer(newLayer)
        newLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        player.play()
    }
    
    func decideNextView(){
        if let token = AppData.readToken() {
            tryReadUser(token: token)
        } else{
            changeView(storyBoardName: "Main", controllerName: "main")
        }
    }
    
    func tryReadUser(token:String) {
        do{
            try ProfileReader.run()
            if let notificationToken = AppData.readNotificationToken() {
                try User.saveFirebaseToken(token: token,pushNotificationToken: notificationToken)
            }
            changeView(storyBoardName: "Map", controllerName: "reveal_controller")
        } catch User.UserError.errorSavingFireBaseToken{
            ProfileReader.delete()
            createAlertInfo(message: "Error con el sistema de notificaciones")
            while !clickedAlertOK {
                
            }
            changeView(storyBoardName: "Main", controllerName: "main")
        } catch {
            ProfileReader.delete()
            createAlertInfo(message: "Error con el inicio de sesion")
            while !clickedAlertOK {
                
            }
            changeView(storyBoardName: "Main", controllerName: "main")
        }
    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    
    private func changeView(storyBoardName:String, controllerName:String){
        let storyBoard = UIStoryboard(name: storyBoardName, bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: controllerName)
        DispatchQueue.main.async {
            self.navigationController?.setViewControllers([nextViewController], animated: true)
            _ = self.navigationController?.popToRootViewController(animated: true)
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
}
