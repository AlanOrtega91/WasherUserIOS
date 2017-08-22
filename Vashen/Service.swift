//
//  Service.swift
//  Vashen
//
//  Created by Alan on 8/1/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation
import CoreData

@objc(Service)
public class Service:NSManagedObject {
    
    static var HTTP_LOCATION = "Service/"
    
    @NSManaged var status:String
    @NSManaged var cleanerName:String
    @NSManaged var car:String
    @NSManaged var service:String
    @NSManaged var price:String
    @NSManaged var serviceDescription:String
    @NSManaged var estimatedTime:String
    @NSManaged var finalTime:Date
    @NSManaged var acceptedTime:Date
    @NSManaged var latitud:Double
    @NSManaged var longitud:Double
    @NSManaged var startedTime:Date
    @NSManaged var cleanerId:String
    @NSManaged var rating:Int16
    @NSManaged var encodedCleanerImage:String
    @NSManaged var id:String
    @NSManaged var metodoDePago:String
    
    public static let OUTSIDE = 1
    public static let OUTSIDE_INSIDE = 2
    
    public static let BIKE = 1
    public static let CAR = 2
    public static let SMALL_VAN = 3
    public static let BIG_VAN = 4
    
    
    public static func newService()->Service{
        return DataBase.newService()
    }
    
    public static func requestService(direccion:String, withLatitud latitud:String, withLongitud longitud:String, withId idService:String, withToken token:String, withCar idCar:String, withFavoriteCar idFavCar:String, conMetodoDePago metodoDePago:String) throws -> Service{
        let url = HttpServerConnection.buildURL(location: HTTP_LOCATION + "RequestService")
        let params = "direccion=&latitud=\(latitud)&longitud=\(longitud)&idServicio=\(idService)&token=\(token)&idCoche=\(idCar)&idCocheFavorito=\(idFavCar)&metodoDePago=\(metodoDePago)"
        do{
            var response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
            if response["estado"] as! String == "error"
            {
                if response["clave"] as! String == "sesion"
                {
                    throw ServiceError.noSessionFound
                } else if response["Status"] as! String == "bloqueo"
                {
                    throw ServiceError.userBlock
                } else {
                    throw ServiceError.errorRequestingService
                }
            }
 
            let parameters = response["servicio"] as! NSDictionary
            let service = Service.newService()
            service.id = parameters["id"] as! String
            service.car = parameters["coche"] as! String
            service.status = parameters["status"] as! String
            service.service = parameters["servicio"] as! String
            service.price = parameters["precio"] as! String
            service.serviceDescription = parameters["descripcion"] as! String
            service.estimatedTime = parameters["tiempoEstimado"] as! String
            if let latitud = parameters["latitud"] as? String {
                service.latitud = Double(latitud)!
            }
            if let longitud = parameters["longitud"] as? String {
                service.longitud = Double(longitud)!
            }
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
            if response["estado"] as! String == "error"
            {
                if response["clave"] as! String == "sesion"
                {
                    throw ServiceError.noSessionFound
                } else {
                    throw ServiceError.errorCancelingRequest
                }
            }

        } catch HttpServerConnection.HttpError.connectionException {
            throw ServiceError.errorCancelingRequest
        }
    }
    
    public static func sendReview(idService:String, rating:Int16, withToken token:String) throws {
        let url = HttpServerConnection.buildURL(location: HTTP_LOCATION + "SendReview")
        let params = "serviceId=\(idService)&rating=\(rating)&token=\(token)"
        do{
            var response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
            if response["estado"] as! String == "error"
            {
                if response["clave"] as! String == "sesion"
                {
                    throw ServiceError.noSessionFound
                } else {
                    throw ServiceError.errorMandandoCalificacion
                }
            }
            
        } catch HttpServerConnection.HttpError.connectionException {
            throw ServiceError.errorMandandoCalificacion
        }
    }
    
    enum ServiceError: Error {
        case noSessionFound
        case userBlock
        case errorRequestingService
        case errorCancelingRequest
        case errorMandandoCalificacion
    }
    
}
