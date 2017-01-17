//
//  AppDelegate.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit
import CoreData
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var stateReceived = 0
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        self.registrerForRemoteNotifications(application: application)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.tokenRefreshNotificaiton),
                         name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
        
        return true
    }
    
    func registrerForRemoteNotifications(application: UIApplication){
        //let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        let pushNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
    }
    
    func tokenRefreshNotificaiton(notification: NSNotification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
        print("FCM InstanceID token: \(refreshedToken)")
        AppData.saveNotificationToken(notificationToken: refreshedToken)
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
        } else {
            print("FCM error reading token")
        }
    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM in app delegate. \(error)")
            } else {
                print("Connected to FCM in app delegate.")
                self.sendNotificationToken()
            }
        }
    }
    
    func sendNotificationToken() {
        do {
            if let token = AppData.readToken() {
                if let fbToken = AppData.readNotificationToken() {
                    try User.saveFirebaseToken(token: token, pushNotificationToken: fbToken)
                }
            }
        } catch {
            
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        var message:String!
        if let state = userInfo["state"] as? String{
            print("Firebase Message\(state)")
            switch state {
            case "2":
                if stateReceived != 2 {
                    stateReceived = 2
                    message = "Tu servicio fue aceptado"
                    AppData.deleteMessage()
                    sendPopUp(message: message)
                    if let serviceJson = userInfo["serviceInfo"] as? String{
                        let data = serviceJson.data(using: String.Encoding.utf8)
                        do {
                            let service = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                            saveNewServiceState(serviceJson: service)
                        } catch {}
                    }
                }
                break
            case "4":
                if stateReceived != 4 {
                    stateReceived = 4
                    message = "Tu servicio comenzo"
                    AppData.deleteMessage()
                    sendPopUp(message: message)
                    if let serviceJson = userInfo["serviceInfo"] as? String{
                        let data = serviceJson.data(using: String.Encoding.utf8)
                        do {
                            let service = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                            saveNewServiceState(serviceJson: service)
                        } catch {}
                    }
                }
                break
            case "5":
                if stateReceived != 5 {
                    stateReceived = 5
                    AppData.deleteMessage()
                    if let serviceJson = userInfo["serviceInfo"] as? String{
                        let data = serviceJson.data(using: String.Encoding.utf8)
                        do {
                            let service = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                            saveNewServiceState(serviceJson: service)
                        } catch {}
                    }
                }
                break
            case "6":
                if stateReceived != 6 {
                    stateReceived = 6
                    AppData.deleteMessage()
                    sendPopUp(message: "Tu servicio fue cancelado")
                    if let serviceJson = userInfo["serviceInfo"] as? String{
                        let data = serviceJson.data(using: String.Encoding.utf8)
                        do {
                            let service = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                            deleteService(serviceJson: service)
                        } catch {}
                    }
                }
                break
            default:
                break
            }
        }
    }
    
    func saveNewServiceState(serviceJson:NSDictionary){
        let id = serviceJson["id"] as! String
        if let service = DataBase.readService(id: id) {
            if let name = serviceJson["nombreLavador"] as? String {
                service.cleanerName = name
            }
            if let cleanerId = serviceJson["idLavador"] as? String {
                service.cleanerId = cleanerId
            }
            if let status = serviceJson["status"] as? String {
                service.status = status
            }
            let format = DateFormatter()
            format.dateFormat = "yyy-MM-dd HH:mm:ss"
            format.locale = Locale(identifier: "us")
            if let finalTime = serviceJson["horaFinalEstimada"] as? String{
                service.finalTime = format.date(from: finalTime)!
            }
            if let startedTime = serviceJson["fechaEmpezado"] as? String {
                service.startedTime = format.date(from: startedTime)!
            }
            if let acceptedTime = serviceJson["fechaAceptado"] as? String{
                service.acceptedTime = format.date(from: acceptedTime)!
            }
            if let rating = serviceJson["Calificacion"] as? Int16{
                service.rating = rating
            } else {
                service.rating = -1
            }
            AppData.notifyNewData(newData: true)
        }
    }
    
    func deleteService(serviceJson:NSDictionary){
        let id = serviceJson["id"] as! String
        if let service = DataBase.readService(id: id) {
            DataBase.deleteService(service: service)
            AppData.notifyNewData(newData: true)
        }
    }
    
    func sendPopUp(message:String){
        AppData.saveMessage(message: message)
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: .prod)
        if let tokenF = FIRInstanceID.instanceID().token() {
            AppData.saveNotificationToken(notificationToken: tokenF)
            connectToFcm()
            print("FCM Token:\(tokenF)")
        } else {
            print("FCM Couldnt save token")
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
        AppData.saveNotificationToken(notificationToken: "")
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        print("Context Saved")
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "alan.Vashen" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Vashen", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreDataV1.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

