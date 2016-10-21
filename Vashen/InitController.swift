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
import AVFoundation

class InitController: UIViewController {
    
    var settings : UserDefaults = UserDefaults.standard
    var token : String = AppData.readToken()
    var clickedAlertOK = false
    
    @IBOutlet var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.animateView()
        DispatchQueue.global().async {
            self.decideNextView()
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
    
    public override func didReceiveMemoryWarning() {
        print("memory warning bato")
    }
    
    
    func decideNextView(){
        if token == "" {
            changeView(storyBoardName: "Main", controllerName: "main")
        } else{
            tryReadUser()
        }
    }
    
    func tryReadUser() {
        do{
            try ProfileReader.run()
            
            if let firebaseToken = FIRInstanceID.instanceID().token() {
                try User.saveFirebaseToken(token: token,pushNotificationToken: firebaseToken)
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
