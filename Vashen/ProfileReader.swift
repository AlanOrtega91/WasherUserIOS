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
    
    var managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    let HTTP_LOCATION = "User/"
    var user = User.newUser()
    var cars = [Car]()
    var services = [Service]()
    var cards = [UserCard]()
    
    public static func run() throws{
        do{
            DataBase.deleteAllTables()
            let profile = ProfileReader()
            if let token = AppData.readToken() {
                try profile.initialRead(token: token)
                AppData.saveData(user: profile.user)
            }
            
        } catch{
            print("Error reading profile")
            throw ProfileReaderError.errorReadingProfile
        }
    }
    
    private func initialRead(token:String) throws{
        let url = HttpServerConnection.buildURL(location: HTTP_LOCATION + "InitialRead")
        let params = "token=\(token)&device=ios"
        do{
            var response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
            if response["estado"] as! String != "ok" {
                throw ProfileReaderError.errorReadingData
            }
            readUser(parameters: response["usuario"] as! NSDictionary)
            readCars(parameters: response["coches"] as! [NSDictionary])
            readHistory(parameters: response["historial"] as! [NSDictionary])
            if let cards = response["tarjeta"] as? NSDictionary {
                readCard(parameters: cards)
            }
        } catch {
            throw ProfileReaderError.errorReadingData
        }
    }
    
    public static func run(email:String, withPassword password:String) throws{
        do{
            DataBase.deleteAllTables()
            let profile = ProfileReader()
            try profile.login(email: email, withPassword: password)
            AppData.saveData(user: profile.user)
        } catch{
            throw ProfileReaderError.errorReadingProfile
        }
    }
    
    private func login(email: String, withPassword password: String) throws{
        let url = HttpServerConnection.buildURL(location: HTTP_LOCATION + "LogIn")
        let params = "email=\(email)&password=\(password)&device=ios"
        do{
            var response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
            if response["estado"] as! String != "ok" {
                throw ProfileReaderError.errorReadingData
            }
            readUser(parameters: response["usuario"] as! NSDictionary)
            readCars(parameters: response["coches"] as! [NSDictionary])
            readHistory(parameters: response["historial"] as! [NSDictionary])
            if let cards = response["tarjeta"] as? NSDictionary {
                readCard(parameters: cards)
            }
        } catch {
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
            if let image = User.getEncodedImageForUser(id: user.id) {
                user.encodedImage = User.saveEncodedImageToFileAndGetPath(imageString: image)!
            }
        }
    }
    
    private func readCars(parameters: [NSDictionary]){
        for carJSON in parameters {
            let car = Car.newCar()
            car.id = carJSON["idVehiculoFavorito"]! as! String
            car.type = carJSON["idVehiculo"]! as! String
            car.color = carJSON["Color"]! as! String
            car.plates = carJSON["Placas"]! as! String
            car.brand = carJSON["Marca"]! as! String
            print(String(describing: carJSON["Favorito"]))
            switch carJSON["Favorito"] as! String {
            case "1":
                car.favorite = true
            default:
                car.favorite = false
            }
            cars.append(car)
        }
    }
    
    private func readHistory(parameters: [NSDictionary]){
        let format = DateFormatter()
        format.locale = Locale(identifier: "us")
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        for serviceJSON in parameters {
            let service = Service.newService()
            service.id = serviceJSON["id"] as! String
            service.car = serviceJSON["coche"] as! String
            service.status = serviceJSON["status"] as! String
            service.service = serviceJSON["servicio"] as! String
            service.price = serviceJSON["precio"] as! String
            service.serviceDescription = serviceJSON["descripcion"] as! String
            
            service.latitud = Double(serviceJSON["latitud"] as! String)!
            service.longitud = Double(serviceJSON["longitud"] as! String)!
            if let id = serviceJSON["idLavador"] as? String {
                service.cleanerId = id
            }
            if let name = serviceJSON["nombreLavador"] as? String {
                service.cleanerName = name
            }
            if let finalTime = serviceJSON["horaFinalEstimada"] as? String{
                service.finalTime = format.date(from: finalTime)!
            }
            if let startedTime = serviceJSON["fechaEmpezado"] as? String {
                service.startedTime = format.date(from: startedTime)!
            }
            if let acceptedTime = serviceJSON["fechaAceptado"] as? String{
                service.acceptedTime = format.date(from: acceptedTime)!
            }
            if let rating = serviceJSON["Calificacion"] as? String{
                service.rating = Int16(rating)!
            } else {
                service.rating = -1
            }
            if let metodoDePago = serviceJSON["metodoDePago"] as? String {
                service.metodoDePago = metodoDePago
            }
            services.append(service)
        }
        
    }
    
    private func readCard(parameters: NSDictionary){
        let card: UserCard = UserCard.newUserCard()
        card.cardNumber = "xxxx-xxxx-xxxx-" + (parameters["cardNumber"] as! String)
        if let month = parameters["cardExpirationMonth"] as? String {
            card.expirationMonth = month
        }
        if let year = parameters["cardExpirationYear"] as? String {
            card.expirationYear = year
        }
        cards.append(card)
    }
    
    public static func delete() {
        AppData.eliminateData()
        DataBase.deleteAllTables()
    }
    
    public enum ProfileReaderError: Error {
        case errorReadingData
        case errorReadingProfile
    }
    
}
