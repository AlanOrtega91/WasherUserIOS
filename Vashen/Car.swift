//
//  Car.swift
//  Vashen
//
//  Created by Alan on 8/1/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation
import CoreData

public class Car {
    
    private static let HTTP_LOCATION = "User/Car/"
    public var id:String!
    public var type:String!
    public var plates:String!
    public var color:String!
    public var favorite:Int = 0
    public var brand: String!
    public var multiplier: Double!
    
    
    public static func addNewFavoriteCar(car:Car, withToken token:String) throws -> String{
        let url = HttpServerConnection.buildURL(location: HTTP_LOCATION + "NewCar")
        let params = "vehiculoId=" + car.type + "&token=" + token + "&color=" + car.color + "&placas=" + car.plates + "&marca=" + car.brand
        do{
            let response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params) as NSDictionary
            
            if response["Status"] as! String == "SESSION ERROR" {
                throw CarError.noSessionFound
            }
            if response["Status"] as! String != "OK" {
                throw CarError.errorAddingCar
            }

            return  String(describing: response["carId"]!)
        } catch HttpServerConnection.HttpError.connectionException{
            throw CarError.errorAddingCar
        }
    }
    
    public static func selectFavoriteCar(carId:String, withToken token:String) throws{
        let url = HttpServerConnection.buildURL(location: HTTP_LOCATION + "SetFavoriteCar")
        let params = "vehiculoFavoritoId=\(carId)&token=\(token)"
        do{
            let response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
            
            if response["Status"] as! String == "SESSION ERROR" {
                throw CarError.noSessionFound
            }
            if response["Status"] as! String != "OK" {
                throw CarError.errorAddingFavoriteCar
            }
            
        } catch HttpServerConnection.HttpError.connectionException{
            throw CarError.errorAddingFavoriteCar
        }
    }
    
    public static func editFavoriteCar(car:Car, withToken token:String) throws {
        let url = HttpServerConnection.buildURL(location: HTTP_LOCATION + "EditCar")
        let params = "vehiculoId=\(car.type!)&vehiculoFavoritoId=\(car.id!)&token=\(token)&color=\(car.color!)&placas=\(car.plates!)&marca=\(car.brand!)"
        do{
            let response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
            
            if response["Status"] as! String == "SESSION ERROR" {
                throw CarError.noSessionFound
            }
            if response["Status"] as! String != "OK" {
                throw CarError.errorEditingCar
            }
            
        } catch HttpServerConnection.HttpError.connectionException{
            throw CarError.errorEditingCar
        }
    }
    
    public static func deleteFavoriteCar(id:String, token:String) throws{
        let url = HttpServerConnection.buildURL(location: HTTP_LOCATION + "DeleteCar")
        let params = "favoriteCarId=" + id + "&token=\(token)"
        do{
            let response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
            
            if response["Status"] as! String == "SESSION ERROR" {
                throw CarError.noSessionFound
            }
            if response["Status"] as! String != "OK" {
                throw CarError.errorDeletingCar
            }
            
        } catch HttpServerConnection.HttpError.connectionException{
            throw CarError.errorDeletingCar
        }
    }
    
    
    public enum CarError: Error{
        case noSessionFound
        case errorAddingCar
        case errorAddingFavoriteCar
        case errorEditingCar
        case errorDeletingCar
    }
}
