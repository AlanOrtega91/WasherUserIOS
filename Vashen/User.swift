//
//  User.swift
//  Vashen
//
//  Created by Alan on 8/1/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation
import CoreData

@objc(User)
public class User:NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var lastName: String
    @NSManaged var email: String
    @NSManaged var phone: String
    @NSManaged var id: String
    @NSManaged var token: String
    @NSManaged var encodedImage: String
    @NSManaged var billingName: String
    @NSManaged var rfc: String
    @NSManaged var billingAddress:String
    @NSManaged var codigo:String
    
    public static let HTTP_LOCATION = "User/"
    
    public static func newUser()->User{
        return DataBase.newUser()
    }
    
    public static func sendNewUser(user: User, withPassword password: String) throws -> User{
        let url = HttpServerConnection.buildURL(location: HTTP_LOCATION + "NewUser")
        //TODO Send encoded string
        var params = "name=" + user.name + "&lastName=" + user.lastName + "&email=" + user.email + "&password=" + password + "&phone=" + user.phone + "&device=ios"
        if user.encodedImage != ""
        {
            let image = User.readImageDataFromFile(name: user.encodedImage)
            let imageData = UIImageJPEGRepresentation(image!, 0.5)
            let encodedB64 = (imageData?.base64EncodedString())!
            params += "&encoded_string=" + encodedB64
        }
        do{
            let response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
            if response["estado"] as! String != "ok"
            {
                if response["clave"] as! String != "pago"
                {
                    throw UserError.errorWithNewUser
                }
            }
            let parameters = response["usuario"] as! NSDictionary
            user.id = parameters["idCliente"]! as! String
            user.token = parameters["Token"]! as! String
            user.codigo = parameters["codigo"]! as! String
            return user
        } catch HttpServerConnection.HttpError.connectionException{
            throw UserError.errorWithNewUser
        }
    }
    
    public func sendChangeUserData(token: String) throws{
        let url = HttpServerConnection.buildURL(location: User.HTTP_LOCATION + "ChangeUserData")
        var params = "newName=" + name + "&newLastName=" + lastName + "&newEmail=" + email + "&token=" + token + "&newPhone=" + phone + "&newBillingName=" + billingName + "&newRFC=" + rfc + "&newBillingAddress=" + billingAddress
        if encodedImage != "" {
            let image = User.readImageDataFromFile(name: encodedImage)
            let imageData = UIImageJPEGRepresentation(image!, 0.5)
            let encodedB64 = (imageData?.base64EncodedString())!
            params += "&encoded_string=" + encodedB64
        }
        do{
            let response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
            if response["estado"] as! String == "error"
            {
                if response["clave"] as! String == "sesion"
                {
                    throw UserError.noSessionFound
                } else
                {
                    throw UserError.errorChangeData
                }
            }
            
        } catch HttpServerConnection.HttpError.connectionException{
            throw UserError.errorChangeData
        }
    }
    
    
    
    public func sendLogout() throws {
        let url = HttpServerConnection.buildURL(location: User.HTTP_LOCATION + "LogOut")
        let params = "email=\(email)"
        do{
            let response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
            if response["estado"] as! String != "ok" {
                throw UserError.errorWithLogOut
            }
            
        } catch HttpServerConnection.HttpError.connectionException{
            throw UserError.errorWithLogOut
        }
    }
    
    public static func saveFirebaseToken(token:String, pushNotificationToken:String) throws {
        let url = HttpServerConnection.buildURL(location: HTTP_LOCATION + "SavePushNotificationToken")
        let params = "token=" + token + "&pushNotificationToken=" + pushNotificationToken
        do{
            let response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)            
            if response["estado"] as! String == "error"
            {
                if response["clave"] as! String == "sesion"
                {
                    throw UserError.noSessionFound
                } else
                {
                    throw UserError.errorSavingFireBaseToken
                }
            }
            
            
        } catch HttpServerConnection.HttpError.connectionException{
            throw UserError.errorSavingFireBaseToken
        }
    }
    
    public static func getEncodedImageForUser(id:String) -> String? {
        let url = URL(string: "http://54.218.50.2/api/imagenes/usuarios/\(id)/profile_image.jpg")!
        do {
            let imageData = try Data.init(contentsOf: url)
            return imageData.base64EncodedString(options: .lineLength64Characters)
        } catch {
            return nil
        }
    }
    
    public static func saveEncodedImageToFileAndGetPath(imageString:String) -> String? {
        let imageName = "profile.jpg"
        if let dataImage = Data(base64Encoded: imageString, options: .ignoreUnknownCharacters) {
            if let image = UIImage(data: dataImage) {
                let fileName = getDocumentsDirectory().appendingPathComponent(imageName)
                do {
                    if let imageToSave = UIImageJPEGRepresentation(image, 0.5) {
                        try imageToSave.write(to: fileName)
                        return imageName
                    }
                } catch {
                    return nil
                }
            }
        }
        return nil
    }
    
    public static func saveImageToFileAndGetPath(image:UIImage) -> String? {
        let imageName = "profile.jpg"
                let fileName = getDocumentsDirectory().appendingPathComponent(imageName)
                do {
                    if let imageToSave = UIImageJPEGRepresentation(image, 0.5) {
                        try imageToSave.write(to: fileName)
                        return imageName
                    }
                } catch {
                    return nil
                }
        return nil
    }
    
    public static func readImageDataFromFile(name:String) -> UIImage? {
        let fileName = getDocumentsDirectory().appendingPathComponent(name)
        let image = UIImage(contentsOfFile: fileName.path)
        return image
    }
    
    public static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    public enum UserError: Error{
        case noSessionFound
        case errorSavingFireBaseToken
        case errorWithNewUser
        case errorChangeData
        case errorWithLogOut
        case errorSavingImage
    }
}
