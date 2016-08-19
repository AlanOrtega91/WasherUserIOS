//
//  ProfileReader.swift
//  Vashen
//
//  Created by Alan on 8/1/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation
import CoreData

public class ProfileReader {
    
    var managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    let HTTP_LOCATION = "User/"
    var user = User()
    var cars = [Car]()
    var services = [Service]()
    var cards = [UserCard]()
    
    public static func run() throws{
        do{
            let profile = ProfileReader()
            let token = AppData.readToken()
            try profile.initialRead(token)
            DataBase.saveUser(profile.user)
            AppData.saveData(profile.user)
            DataBase.saveCars(profile.cars)
            DataBase.saveServices(profile.services)
            if profile.cards.count > 0 {
                DataBase.saveCard(profile.cards[0])
            }
            
        } catch{
            print("Error reading profile")
            throw ProfileReaderError.errorReadingProfile
        }
    }
    
    private func initialRead(token:String) throws{
        let url = HttpServerConnection.buildURL(HTTP_LOCATION + "InitialRead")
        let params = "token=\(token)"
        do{
            var response = try HttpServerConnection.sendHttpRequestPost(url, withParams: params)
            if response["Status"] as! String != "OK" {
                throw ProfileReaderError.errorReadingData
            }
            readUser(response["User Info"] as! NSDictionary)
            readCars(response["carsList"] as! Array<NSDictionary>)
            readHistory(response["History"] as! Array<NSDictionary>)
            if let cards = response["cards"] as? NSDictionary {
                readCard(cards)
            }
        } catch (let e) {
            print(e)
            throw ProfileReaderError.errorReadingData
        }
    }
    
    public static func run(email:String, withPassword password:String) throws{
        do{
            let profile = ProfileReader()
            try profile.login(email, withPassword: password)
            DataBase.saveUser(profile.user)
            AppData.saveData(profile.user)
            DataBase.saveCars(profile.cars)
            DataBase.saveServices(profile.services)
            if profile.cards.count > 0  {
                DataBase.saveCard(profile.cards[0])
            }
        } catch{
            print("Error reading profile")
            throw ProfileReaderError.errorReadingProfile
        }
    }
    
    private func login(email: String, withPassword password: String) throws{
        let url = HttpServerConnection.buildURL(HTTP_LOCATION + "LogIn")
        let params = "email=\(email)&password=\(password)"
        do{
            var response = try HttpServerConnection.sendHttpRequestPost(url, withParams: params)
            if response["Status"] as! String != "OK" {
                throw ProfileReaderError.errorReadingData
            }
            readUser(response["User Info"] as! NSDictionary)
            readCars(response["carsList"] as! Array<NSDictionary>)
            readHistory(response["History"] as! Array<NSDictionary>)
            if (response["cards"] != nil) {
                readCard(response["cards"] as! NSDictionary)
            }
        } catch (let e) {
            print(e)
            throw ProfileReaderError.errorReadingData
        }
    }
    
    private func readUser(parameters: NSDictionary){
        user.name = parameters["Nombre"]! as! String
        user.lastName = parameters["PrimerApellido"]! as! String
        user.email = parameters["Email"]! as! String
        user.id = parameters["idCliente"]! as! String
        user.token = parameters["Token"]! as! String
        user.phone = parameters["Telefono"]! as! String
        if let billingName = parameters["NombreFactura"] as? String{
            user.billingName = billingName
        }
        if let rfc = parameters["RFC"] as? String{
            user.rfc = rfc
        }
        if let billingAddress = parameters["DireccionFactura"] as? String{
            user.billingAddress = billingAddress
        }
        if (parameters["FotoURL"] as? String) != nil{
            user.encodedImage = User.getEncodedImageForUser(user.id)
        }
    }
    
    private func readCars(parameters: Array<NSDictionary>){
        for carJSON in parameters {
            let car: Car = Car()
            car.id = carJSON["idVehiculoFavorito"]! as! String
            car.type = carJSON["idVehiculo"]! as! String
            car.color = carJSON["Color"]! as! String
            car.plates = carJSON["Placas"]! as! String
            car.model = carJSON["Modelo"]! as! String
            car.brand = carJSON["Marca"]! as! String
            car.multiplier = Double(carJSON["Multiplicador"] as! String)!
            car.favorite = Int(carJSON["Favorito"] as! String)!
            cars.append(car)
        }
    }
    
    private func readHistory(parameters: Array<NSDictionary>){
        for serviceJSON in parameters {
            let service: Service = Service()
            service.id = serviceJSON["id"] as! String
            service.car = serviceJSON["coche"] as! String
            service.status = serviceJSON["status"] as! String
            service.service = serviceJSON["servicio"] as! String
            service.price = serviceJSON["precio"] as! String
            service.description = serviceJSON["descripcion"] as! String
            
            service.latitud = Double(serviceJSON["latitud"] as! String)!
            service.longitud = Double(serviceJSON["longitud"] as! String)!
            service.cleanerId = serviceJSON["idLavador"] as? String
            service.cleanerName = serviceJSON["nombreLavador"] as? String
            
            let format = NSDateFormatter()
            format.dateFormat = "yyy-MM-dd HH:mm:ss"
            if let finalTime = serviceJSON["horaFinalEstimada"] as? String{
                service.finalTime = format.dateFromString(finalTime)
            }
            if let startedTime = serviceJSON["fechaEmpezado"] as? String {
                service.startedTime = format.dateFromString(startedTime)
            }
            if let acceptedTime = serviceJSON["fechaAceptado"] as? String{
                service.acceptedTime = format.dateFromString(acceptedTime)
            }
            if let rating = serviceJSON["Calificacion"] as? String{
                service.rating = Int(rating)!
            } else {
                service.rating = -1
            }
            services.append(service)
        }
        
    }
    
    private func readCard(parameters: NSDictionary){
        let card: UserCard = UserCard()
        card.cardNumber = parameters["cardNumber"] as! String
        card.expirationDate = parameters["cardExpiration"] as! String
        cards.append(card)
    }
    
    public static func delete() {
        AppData.eliminateData()
        DataBase.deleteAllTables()
    }
    
    public enum ProfileReaderError: ErrorType {
        case errorReadingData
        case errorReadingProfile
    }
    
}