//
//  AppData.swift
//  Vashen
//
//  Created by Alan on 8/1/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation

public class AppData {
    
    
        static var TOKEN  = "token"
        static var IDCLIENT  = "idClient"
        static var SENT_ALERT  = "alert"
        static var IN_BACKGROUND  = "inBackground"
        static var FB_TOKEN  = "fireBase"
        static var MESSAGE  = "notificationMessage"
        static var SERVICE_CHANGED  = "serviceChanged"
    
    public static func saveData(user: User){
        let settings : UserDefaults = UserDefaults.standard
        settings.set(user.token, forKey: TOKEN)
        settings.set(user.id, forKey: IDCLIENT)
    }
    
    public static func readToken() -> String{
        let settings : UserDefaults = UserDefaults.standard
        if let token = settings.string(forKey: TOKEN) {
            return token
        } else {
            return ""
        }
    }
    
    public static func readUserId() -> String{
        let settings : UserDefaults = UserDefaults.standard
        if let idClient = settings.string(forKey: IDCLIENT) {
            return idClient
        } else {
            return ""
        }
    }
    
    public static func readFirebaseToken() -> String{
        let settings : UserDefaults = UserDefaults.standard
        if let firebaseToken = settings.string(forKey: FB_TOKEN) {
            return firebaseToken
        } else {
            return ""
        }
    }
    
    public static func newData() -> Bool{
        let settings : UserDefaults = UserDefaults.standard
        let newData = settings.bool(forKey: SERVICE_CHANGED)
        return newData
    }
    public static func notifyNewData(newData:Bool){
        let settings : UserDefaults = UserDefaults.standard
        settings.set(newData, forKey: SERVICE_CHANGED)
    }
    
    public static func saveMessage(message:String){
        let settings : UserDefaults = UserDefaults.standard
        settings.set(message, forKey: MESSAGE)
    }
    
    public static func deleteMessage() {
        let settings : UserDefaults = UserDefaults.standard
        settings.removeObject(forKey: MESSAGE)
    }
    
    public static func getMessage() -> String {
        let settings : UserDefaults = UserDefaults.standard
        if let message = settings.string(forKey: MESSAGE) {
            return message
        } else {
            return ""
        }
    }
    
    public static func eliminateData() {
        let settings : UserDefaults = UserDefaults.standard
        settings.removeObject(forKey: TOKEN)
        settings.removeObject(forKey: SENT_ALERT)
        settings.removeObject(forKey: IDCLIENT)
    }
}
