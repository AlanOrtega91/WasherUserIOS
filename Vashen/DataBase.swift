//
//  DataBase.swift
//  Vashen
//
//  Created by Alan on 8/9/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation
import CoreData

public class DataBase {
    
    public static func deleteTable(table:String, context: NSManagedObjectContext) throws{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: table)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do{
            try context.execute(deleteRequest)
        } catch{
            throw errorSavingData
        }
    }
    
    public static func saveUser(user:User){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        do{
            try deleteTable(table: "User",context: context)
            let newUser = NSEntityDescription.insertNewObject(forEntityName: "User", into: context)
            
            newUser.setValue(user.id, forKey: "id")
            newUser.setValue(user.name, forKey: "name")
            newUser.setValue(user.lastName, forKey: "lastName")
            newUser.setValue(user.email, forKey: "email")
            newUser.setValue(user.phone, forKey: "phone")
            newUser.setValue(user.encodedImage, forKey: "encodedImage")
            newUser.setValue(user.billingName, forKey: "billingName")
            newUser.setValue(user.rfc, forKey: "rfc")
            newUser.setValue(user.billingAddress, forKey: "billingAddress")
            
            try context.save()
        } catch {
            
        }
    }
    
    public static func readUser() -> User{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchRequest.returnsObjectsAsFaults = false
        let user: User = User()
        do {
            let results = try context.fetch(fetchRequest)[0] as! NSManagedObject
            user.id = results.value(forKey: "id") as! String
            user.name = results.value(forKey: "name") as! String
            user.lastName = results.value(forKey: "lastName") as! String
            user.email = results.value(forKey: "email") as! String
            user.phone = results.value(forKey: "phone") as! String
            user.encodedImage = results.value(forKey: "encodedImage") as? String
            user.billingName = results.value(forKey: "billingName") as? String
            user.rfc = results.value(forKey: "rfc") as? String
            user.billingAddress = results.value(forKey: "billingAddress") as? String
            return user
        } catch {
            return user
        }
    }
    
    
    public static func saveCars(cars: Array<Car>){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        
        do{
            try deleteTable(table: "Car",context: context)
        for car in cars {
            let newCar = NSEntityDescription.insertNewObject(forEntityName: "Car", into: context)
            newCar.setValue(car.id, forKey: "id")
            newCar.setValue(car.type, forKey: "type")
            newCar.setValue(car.color, forKey: "color")
            newCar.setValue(car.plates, forKey: "plates")
            newCar.setValue(car.model, forKey: "model")
            newCar.setValue(car.brand, forKey: "brand")
            newCar.setValue(car.favorite, forKey: "favorite")
            try context.save()
        }
        } catch {
            
        }
    }
    
    public static func readCars() -> Array<Car>{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Car")
        fetchRequest.returnsObjectsAsFaults = false
        var cars: Array<Car> = Array<Car>()
        do {
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            
            for carResult in results {
                let car: Car = Car()
                car.id = carResult.value(forKey: "id") as! String
                car.type = carResult.value(forKey: "type") as! String
                car.color = carResult.value(forKey: "color") as! String
                car.plates = carResult.value(forKey: "plates") as! String
                car.model = carResult.value(forKey: "model") as! String
                car.brand = carResult.value(forKey: "brand") as! String
                car.favorite = carResult.value(forKey: "favorite") as! Int
                cars.append(car)
            }
            return cars
        } catch {
            return cars
        }
    }
    
    public static func getFavoriteCar() -> Car?{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Car")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "favorite == %@", "1")
        let car: Car = Car()
        do {
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            if results.count > 0 {
                car.id = results[0].value(forKey: "id") as! String
                car.type = results[0].value(forKey: "type") as! String
                car.color = results[0].value(forKey: "color") as! String
                car.plates = results[0].value(forKey: "plates") as! String
                car.model = results[0].value(forKey: "model") as! String
                car.brand = results[0].value(forKey: "brand") as! String
                car.favorite = results[0].value(forKey: "favorite") as! Int
                
                return car
            }
            return nil
        } catch {
            return nil
        }
    }
    
    
    public static func setFavoriteCar(id: String) {
        let cars: Array<Car> = readCars()
        var carsToSave: Array<Car> = Array<Car>()
        for car in cars {
            car.favorite = 0
            if car.id == id {
                car.favorite = 1
            }
            carsToSave.append(car)
        }
        saveCars(cars: carsToSave)
    }
    
    public static func saveServices(services: Array<Service>) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        
        do{
            try deleteTable(table: "Service",context: context)
            for service in services {
                let newService = NSEntityDescription.insertNewObject(forEntityName: "Service", into: context)
                newService.setValue(service.id, forKey: "id")
                newService.setValue(service.car, forKey: "car")
                newService.setValue(service.cleanerName, forKey: "cleanerName")
                newService.setValue(service.service, forKey: "service")
                newService.setValue(service.price, forKey: "price")
                newService.setValue(service.description, forKey: "serviceDescription")
                newService.setValue(service.startedTime, forKey: "startedTime")
                newService.setValue(service.latitud, forKey: "latitud")
                newService.setValue(service.longitud, forKey: "longitud")
                newService.setValue(service.status, forKey: "status")
                newService.setValue(service.rating, forKey: "rating")
                newService.setValue(service.cleanerId, forKey: "cleanerId")
                newService.setValue(service.finalTime, forKey: "finalTime")
                newService.setValue(service.acceptedTime, forKey: "acceptedTime")
                try context.save()
            }
        } catch {
            //Didnt save
        }
    }
    
    public static func readServices() -> Array<Service>?{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Service")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "acceptedTime", ascending: false)]
        do {
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            var services: Array<Service> = Array<Service>()
            for serviceResult in results {
                let service: Service = Service()
                service.id = serviceResult.value(forKey: "id") as! String
                service.car = serviceResult.value(forKey: "car") as! String
                service.cleanerName = serviceResult.value(forKey: "cleanerName") as? String
                service.service = serviceResult.value(forKey: "service") as! String
                service.price = serviceResult.value(forKey: "price") as! String
                service.description = serviceResult.value(forKey: "description") as! String
                service.startedTime = serviceResult.value(forKey: "startedTime") as? Date
                service.latitud = serviceResult.value(forKey: "latitud") as! Double
                service.longitud = serviceResult.value(forKey: "longitud") as! Double
                service.status = serviceResult.value(forKey: "status") as! String
                service.rating = serviceResult.value(forKey: "rating") as! Int
                service.cleanerId = serviceResult.value(forKey: "cleanerId") as? String
                service.finalTime = serviceResult.value(forKey: "finalTime") as? Date
                service.acceptedTime = serviceResult.value(forKey: "acceptedTime") as? Date
                services.append(service)
            }
            return services
        } catch {
            return nil
        }
    }
    
    public static func getActiveService() -> Service?{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Service")
        fetchRequest.returnsObjectsAsFaults = false
        let statusPredicate = NSPredicate(format: "status != %@", "Canceled")
        let ratingPredicate = NSPredicate(format: "rating == %@", "-1")
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [statusPredicate, ratingPredicate])
        
        do {
            if try context.fetch(fetchRequest).count > 0 {
                let results = try context.fetch(fetchRequest)[0]  as! NSManagedObject
                let service: Service = Service()
                service.id = results.value(forKey: "id") as! String
                service.car = results.value(forKey: "car") as! String
                service.cleanerName = results.value(forKey: "cleanerName") as? String
                service.service = results.value(forKey: "service") as! String
                service.price = results.value(forKey: "price") as! String
                service.description = results.value(forKey: "description") as! String
                service.startedTime = results.value(forKey: "startedTime") as?  Date
                service.latitud = results.value(forKey: "latitud") as! Double
                service.longitud = results.value(forKey: "longitud") as! Double
                service.status = results.value(forKey: "status") as! String
                service.rating = results.value(forKey: "rating") as! Int
                service.cleanerId = results.value(forKey: "cleanerId") as? String
                service.finalTime = results.value(forKey: "finalTime") as?  Date
                service.acceptedTime = results.value(forKey: "acceptedTime") as?  Date
                return service
            }
            return nil
        } catch {
            return nil
        }
    }
    
    public static func getFinishedServices() -> Array<Service>{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Service")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "acceptedTime", ascending: false)]
        let statusPredicate = NSPredicate(format: "status == %@", "Finished")
        let ratingPredicate = NSPredicate(format: "rating != %@", "-1")
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [statusPredicate, ratingPredicate])
        var services: Array<Service> = Array<Service>()
        do {
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            for serviceResult in results {
                let service: Service = Service()
                
                service.id = serviceResult.value(forKey: "id") as! String
                service.car = serviceResult.value(forKey: "car") as! String
                service.cleanerName = serviceResult.value(forKey: "cleanerName") as! String
                service.service = serviceResult.value(forKey: "service") as! String
                service.price = serviceResult.value(forKey: "price") as! String
                service.description = serviceResult.value(forKey: "description") as! String
                service.startedTime = serviceResult.value(forKey: "startedTime") as? Date
                service.latitud = serviceResult.value(forKey: "latitud") as! Double
                service.longitud = serviceResult.value(forKey: "longitud") as! Double
                service.status = serviceResult.value(forKey: "status") as! String
                service.rating = serviceResult.value(forKey: "rating") as! Int
                service.cleanerId = serviceResult.value(forKey: "cleanerId") as! String
                service.finalTime = serviceResult.value(forKey: "finalTime") as? Date
                service.acceptedTime = serviceResult.value(forKey: "acceptedTime") as? Date
                services.append(service)
            }
            return services
        } catch {
            return services
        }
    }
    
    public static func saveCard(card:UserCard){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        do{
            try deleteTable(table: "UserCard",context: context)
            let newCard = NSEntityDescription.insertNewObject(forEntityName: "UserCard", into: context)
            
            newCard.setValue(card.cardNumber, forKey: "cardNumber")
            newCard.setValue(card.expirationMonth + "/" + card.expirationYear, forKey: "expirationDate")
            
            try context.save()
        } catch {
            
        }
    }
    
    public static func readCard() -> UserCard?{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserCard")
        fetchRequest.returnsObjectsAsFaults = false
        let card: UserCard = UserCard()
        do {
            
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            if results.count > 0 {
                card.cardNumber = results[0].value(forKey: "cardNumber") as! String
                let expirationDate = results[0].value(forKey: "expirationDate") as! String
                card.expirationMonth = expirationDate.components(separatedBy: "/")[0]
                card.expirationYear = expirationDate.components(separatedBy: "/")[1]
                return card
            }
            return nil
        } catch {
            return nil
        }
    }
    
    public static func deleteAllTables() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        do{
        try deleteTable(table: "User", context: context)
         try deleteTable(table: "Service", context: context)
         try deleteTable(table: "Car", context: context)
         try deleteTable(table: "UserCard", context: context)
            
        } catch {
            
        }
    }

    public static var errorSavingData: Error!
}
