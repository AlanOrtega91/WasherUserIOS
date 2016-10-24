//
//  UserCard.swift
//  Vashen
//
//  Created by Alan on 8/1/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation
import CoreData

public class UserCard {
    static var HTTP_LOCATION = "User/Card/"
    public var expirationYear: String!
    public var expirationMonth:String!
    public var cardNumber: String!
    public var cvv: String!
    public var token: String!
    
    public static func saveNewCardToken(token:String, withCard cardToken:String)throws {
        let url = HttpServerConnection.buildURL(location: HTTP_LOCATION + "SaveNewCard")
        let params = "token=\(token)&cardToken=\(cardToken)"
        do{
            var response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
            if response["Status"] as! String != "OK" {
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
