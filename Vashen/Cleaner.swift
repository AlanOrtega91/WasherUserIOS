//
//  Cleaner.swift
//  Vashen
//
//  Created by Alan on 8/17/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation

public class Cleaner{
    static var HTTP_LOCATION = "Service/"
    public var id:String!
    public var name:String!
    public var lastName:String!
    public var latitud:Double!
    public var longitud:Double!
    
    
    public static func getNearbyCleaners(latitud:Double, longitud:Double, withToken token:String)throws -> Array<Cleaner>{
        let url = HttpServerConnection.buildURL(HTTP_LOCATION + "GetNearbyCleaners")
        let params = "latitud=\(latitud)&longitud=\(longitud)&token=\(token)"
        var cleaners:Array<Cleaner> = Array<Cleaner>()
        do{
            var response = try HttpServerConnection.sendHttpRequestPost(url, withParams: params)
            if response["Status"] as! String == "SESSION ERROR" {
                throw Error.noSessionFound
            }
            if response["Status"] as! String != "OK" {
                throw Error.errorGettingCleaners
            }
            let parameters = response["cleaners"] as! Array<NSDictionary>
            for json:NSDictionary in parameters {
                let cleaner = Cleaner()
                cleaner.id = json["idLavador"] as! String
                cleaner.name = json["Nombre"] as! String
                cleaner.lastName = json["PrimerApellido"] as! String
                cleaner.latitud = Double(json["Latitud"] as! String)
                cleaner.longitud = Double(json["Longitud"] as! String)
                cleaners.append(cleaner)
            }
            return cleaners
        } catch{
            throw Error.errorGettingCleaners
        }
    }
    
    public static func getCleanerLocation(cleanerId:String, withToken token:String)throws -> Cleaner{
        let url = HttpServerConnection.buildURL(HTTP_LOCATION + "GetCleanerLocation")
        let params = "cleanerId=\(cleanerId)&token=\(token)"
        do{
            var response = try HttpServerConnection.sendHttpRequestPost(url, withParams: params)
            if response["Status"] as! String == "SESSION ERROR" {
                throw Error.noSessionFound
            }
            if response["Status"] as! String != "OK" {
                throw Error.errorGettingCleaners
            }
            let parameters = response["cleaner"] as! NSDictionary
            let cleaner = Cleaner()
            cleaner.id = parameters["idLavador"] as! String
            cleaner.latitud = Double(parameters["Latitud"] as! String)
            cleaner.longitud = Double(parameters["Longitud"] as! String)
            return cleaner
        } catch{
            throw Error.errorGettingCleaners
        }
    }
    
    enum Error:ErrorType {
        case noSessionFound
        case errorGettingCleaners
    }
}