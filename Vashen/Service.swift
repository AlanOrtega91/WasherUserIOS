//
//  Service.swift
//  Vashen
//
//  Created by Alan on 8/1/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation

public class Service {
    
    static var HTTP_LOCATION = "Service/"
    public var status:String!
    public var cleanerName:String!
    public var car:String!
    public var service:String!
    public var price:String!
    public var description:String!
    public var estimatedTime:String!
    public var finalTime:Date!
    public var acceptedTime:Date!
    public var latitud:Double!
    public var longitud:Double!
    public var startedTime:Date!
    public var cleanerId:String!
    public var rating:Int!
    public var encodedCleanerImage:String!
    public var id:String!
    
    public static let ECO = 2
    public static let TRADITIONAL = 1
    public static let OUTSIDE = 1
    public static let OUTSIDE_INSIDE = 2
    public static let BIKE = 1
    public static let SMALL_CAR = 2
    public static let BIG_CAR = 3
    public static let SMALL_VAN = 4
    public static let BIG_VAN = 5
    
    public static func requestService(direccion:String, withLatitud latitud:String, withLongitud longitud:String, withId idService:String, withType idServiceType:String, withToken token:String, withCar idCar:String, withFavoriteCar idFavCar:String) throws -> Service{
        let url = HttpServerConnection.buildURL(location: HTTP_LOCATION + "RequestService")
        let params = "direccion=\(direccion)&latitud=\(latitud)&longitud=\(longitud)&idServicio=\(idService)&idTipoServicio=\(idServiceType)&token=\(token)&idCoche=\(idCar)&idCocheFavorito=\(idFavCar)"
        do{
            var response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
            if response["Status"] as! String == "SESSION ERROR" {
                throw ServiceError.noSessionFound
            }
            if response["Status"] as! String == "USER BLOCK" {
                throw ServiceError.userBlock
            }
            if response["Status"] as! String != "OK" {
                throw ServiceError.errorRequestingService
            }
            let parameters = response["info"] as! NSDictionary
            let service = Service()
            service.id = parameters["id"] as! String
            service.car = parameters["coche"] as! String
            service.status = parameters["status"] as! String
            service.service = parameters["servicio"] as! String
            service.price = parameters["precio"] as! String
            service.description = parameters["descripcion"] as! String
            service.estimatedTime = parameters["tiempoEstimado"] as! String
            service.latitud = Double(parameters["latitud"] as! String)
            service.longitud = Double(parameters["longitud"] as! String)
            service.rating = -1
            return service
        } catch HttpServerConnection.HttpError.connectionException {
            throw ServiceError.errorRequestingService
        }
    
    }
    
    public static func cancelService(idService:String, withToken token:String, withTimeOutCancel timeOutCancel:Int)throws {
        let url = HttpServerConnection.buildURL(location: HTTP_LOCATION + "ChangeServiceStatus")
        let params = "serviceId=\(idService)&statusId=6&token=\(token)&cancelCode=\(timeOutCancel)"
        do{
            var response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
            if response["Status"] as! String == "SESSION ERROR" {
                throw ServiceError.noSessionFound
            }
            if response["Status"] as! String != "OK" {
                throw ServiceError.errorCancelingRequest
            }

        } catch HttpServerConnection.HttpError.connectionException {
            throw ServiceError.errorCancelingRequest
        }
    }
    
    public static func sendReview(idService:String, rating:Int, withToken token:String) throws {
        let url = HttpServerConnection.buildURL(location: HTTP_LOCATION + "SendReview")
        let params = "serviceId=\(idService)&rating=\(rating)&token=\(token)"
        do{
            var response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
            if response["Status"] as! String == "SESSION ERROR" {
                throw ServiceError.noSessionFound
            }
            if response["Status"] as! String != "OK" {
                throw ServiceError.errorCancelingRequest
            }
            
        } catch HttpServerConnection.HttpError.connectionException {
            throw ServiceError.errorCancelingRequest
        }
    }
    
    enum ServiceError: Error {
        case noSessionFound
        case userBlock
        case errorRequestingService
        case errorCancelingRequest
    }
    
}
