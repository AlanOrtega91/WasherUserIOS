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
            self.iniciar()
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
    
    
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(String(describing: error))")
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
    
    func mostrarNuevaActualizacion(){
            let alert = UIAlertController(title: "Existe una nueva actualizacion",
                                          message: "Descarga la nueva version", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Descargar", style: UIAlertActionStyle.default, handler: {action in
                if let url = URL(string: "itms-apps://itunes.apple.com/app/id1187936862?mt=8") {
                    UIApplication.shared.openURL(url)
                }
            }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func iniciar() {
        if let token = AppData.readToken() {
            do {
                try Versiones.leerVersion()
                try tryReadUser(token: token)
            } catch Versiones.VersionesError.actualizacionRequerida {
                self.mostrarNuevaActualizacion()
            }catch {
                changeView(storyBoardName: "Main", controllerName: "main")
            }
        } else{
            changeView(storyBoardName: "Main", controllerName: "main")
        }
    }
    
    func tryReadUser(token:String) throws {
        try ProfileReader.run()
        if let notificationToken = AppData.readNotificationToken() {
            try User.saveFirebaseToken(token: token,pushNotificationToken: notificationToken)
        }
        changeView(storyBoardName: "Map", controllerName: "reveal_controller")
    }
}
