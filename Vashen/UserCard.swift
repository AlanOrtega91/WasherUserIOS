//
//  UserCard.swift
//  Vashen
//
//  Created by Alan on 8/1/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation
import CoreData

@objc(UserCard)
public class UserCard:NSManagedObject {
    
    static var HTTP_LOCATION = "User/Card/"
    
    @NSManaged var expirationYear: String
    @NSManaged var expirationMonth:String
    @NSManaged var cardNumber: String
    @NSManaged var cvv: String
    @NSManaged var token: String
    
    public static func newUserCard()->UserCard{
        return DataBase.newUserCard()
    }
    
    public static func saveNewCardToken(token:String, withCard cardToken:String)throws {
        let url = HttpServerConnection.buildURL(location: HTTP_LOCATION + "SaveNewCard")
        let params = "token=\(token)&cardToken=\(cardToken)"
        do{
            var response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
            if response["estado"] as! String != "ok" {
                throw UserCardError.errorSavingCard
            }
            
        } catch HttpServerConnection.HttpError.connectionException {
            throw UserCardError.errorSavingCard
        }
    }
    
    enum UserCardError: Error {
        case errorSavingCard
    }
}
