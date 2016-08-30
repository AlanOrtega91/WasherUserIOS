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
        let fetchRequest = NSFetchRequest(entityName: table)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do{
            try context.executeRequest(deleteRequest)
        } catch{
            throw errorSavingData
        }
    }
    
    public static func saveUser(user:User){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        do{
            try deleteTable("User",context: context)
            let newUser = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: context)
            
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
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "User")
        fetchRequest.returnsObjectsAsFaults = false
        let user: User = User()
        do {
            let results = try context.executeFetchRequest(fetchRequest)[0]
            user.id = results.valueForKey("id") as! String
            user.name = results.valueForKey("name") as! String
            user.lastName = results.valueForKey("lastName") as! String
            user.email = results.valueForKey("email") as! String
            user.phone = results.valueForKey("phone") as! String
            user.encodedImage = results.valueForKey("encodedImage") as? String
            user.billingName = results.valueForKey("billingName") as? String
            user.rfc = results.valueForKey("rfc") as? String
            user.billingAddress = results.valueForKey("billingAddress") as? String
            return user
        } catch {
            return user
        }
    }
    
    
    public static func saveCars(cars: Array<Car>){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        
        do{
            try deleteTable("Car",context: context)
        for car in cars {
            let newCar = NSEntityDescription.insertNewObjectForEntityForName("Car", inManagedObjectContext: context)
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
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Car")
        fetchRequest.returnsObjectsAsFaults = false
        var cars: Array<Car> = Array<Car>()
        do {
            let results = try context.executeFetchRequest(fetchRequest)
            
            for carResult in results {
                let car: Car = Car()
                car.id = carResult.valueForKey("id") as! String
                car.type = carResult.valueForKey("type") as! String
                car.color = carResult.valueForKey("color") as! String
                car.plates = carResult.valueForKey("plates") as! String
                car.model = carResult.valueForKey("model") as! String
                car.brand = carResult.valueForKey("brand") as! String
                car.favorite = carResult.valueForKey("favorite") as! Int
                cars.append(car)
            }
            return cars
        } catch {
            return cars
        }
    }
    
    public static func getFavoriteCar() -> Car?{
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Car")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "favorite == %@", "1")
        let car: Car = Car()
        do {
            let results = try context.executeFetchRequest(fetchRequest)
            if results.count > 0 {
                car.id = results[0].valueForKey("id") as! String
                car.type = results[0].valueForKey("type") as! String
                car.color = results[0].valueForKey("color") as! String
                car.plates = results[0].valueForKey("plates") as! String
                car.model = results[0].valueForKey("model") as! String
                car.brand = results[0].valueForKey("brand") as! String
                car.favorite = results[0].valueForKey("favorite") as! Int
                
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
        saveCars(carsToSave)
    }
    
    public static func saveServices(services: Array<Service>) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        
        do{
            try deleteTable("Service",context: context)
            for service in services {
                let newService = NSEntityDescription.insertNewObjectForEntityForName("Service", inManagedObjectContext: context)
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
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Service")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "acceptedTime", ascending: false)]
        do {
            let results = try context.executeFetchRequest(fetchRequest)
            var services: Array<Service> = Array<Service>()
            for serviceResult in results {
                let service: Service = Service()
                service.id = serviceResult.valueForKey("id") as! String
                service.car = serviceResult.valueForKey("car") as! String
                service.cleanerName = serviceResult.valueForKey("cleanerName") as? String
                service.service = serviceResult.valueForKey("service") as! String
                service.price = serviceResult.valueForKey("price") as! String
                service.description = serviceResult.valueForKey("description") as! String
                service.startedTime = serviceResult.valueForKey("startedTime") as? NSDate
                service.latitud = serviceResult.valueForKey("latitud") as! Double
                service.longitud = serviceResult.valueForKey("longitud") as! Double
                service.status = serviceResult.valueForKey("status") as! String
                service.rating = serviceResult.valueForKey("rating") as! Int
                service.cleanerId = serviceResult.valueForKey("cleanerId") as? String
                service.finalTime = serviceResult.valueForKey("finalTime") as? NSDate
                service.acceptedTime = serviceResult.valueForKey("acceptedTime") as? NSDate
                services.append(service)
            }
            return services
        } catch {
            return nil
        }
    }
    
    public static func getActiveService() -> Service?{
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Service")
        fetchRequest.returnsObjectsAsFaults = false
        let statusPredicate = NSPredicate(format: "status != %@", "Canceled")
        let ratingPredicate = NSPredicate(format: "rating == %@", "-1")
        fetchRequest.predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [statusPredicate, ratingPredicate])
        
        do {
            if try context.executeFetchRequest(fetchRequest).count > 0 {
                let results = try context.executeFetchRequest(fetchRequest)[0]
                let service: Service = Service()
                service.id = results.valueForKey("id") as! String
                service.car = results.valueForKey("car") as! String
                service.cleanerName = results.valueForKey("cleanerName") as? String
                service.service = results.valueForKey("service") as! String
                service.price = results.valueForKey("price") as! String
                service.description = results.valueForKey("description") as! String
                service.startedTime = results.valueForKey("startedTime") as? NSDate
                service.latitud = results.valueForKey("latitud") as! Double
                service.longitud = results.valueForKey("longitud") as! Double
                service.status = results.valueForKey("status") as! String
                service.rating = results.valueForKey("rating") as! Int
                service.cleanerId = results.valueForKey("cleanerId") as? String
                service.finalTime = results.valueForKey("finalTime") as? NSDate
                service.acceptedTime = results.valueForKey("acceptedTime") as? NSDate
                return service
            }
            return nil
        } catch {
            return nil
        }
    }
    
    public static func getFinishedServices() -> Array<Service>{
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Service")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "acceptedTime", ascending: false)]
        let statusPredicate = NSPredicate(format: "status == %@", "Finished")
        let ratingPredicate = NSPredicate(format: "rating != %@", "-1")
        fetchRequest.predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [statusPredicate, ratingPredicate])
        var services: Array<Service> = Array<Service>()
        do {
            let results = try context.executeFetchRequest(fetchRequest)
            for serviceResult in results {
                let service: Service = Service()
                service.id = serviceResult.valueForKey("id") as! String
                service.car = serviceResult.valueForKey("car") as! String
                service.cleanerName = serviceResult.valueForKey("cleanerName") as! String
                service.service = serviceResult.valueForKey("service") as! String
                service.price = serviceResult.valueForKey("price") as! String
                service.description = serviceResult.valueForKey("description") as! String
                service.startedTime = serviceResult.valueForKey("startedTime") as! NSDate
                service.latitud = serviceResult.valueForKey("latitud") as! Double
                service.longitud = serviceResult.valueForKey("longitud") as! Double
                service.status = serviceResult.valueForKey("status") as! String
                service.rating = serviceResult.valueForKey("rating") as! Int
                service.cleanerId = serviceResult.valueForKey("cleanerId") as! String
                service.finalTime = serviceResult.valueForKey("finalTime") as! NSDate
                service.acceptedTime = serviceResult.valueForKey("acceptedTime") as! NSDate
                services.append(service)
            }
            return services
        } catch {
            return services
        }
    }
    
    public static func saveCard(card:UserCard){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        do{
            try deleteTable("UserCard",context: context)
            let newCard = NSEntityDescription.insertNewObjectForEntityForName("UserCard", inManagedObjectContext: context)
            
            newCard.setValue(card.cardNumber, forKey: "cardNumber")
            newCard.setValue(card.expirationDate, forKey: "expirationDate")
            
            try context.save()
        } catch {
            
        }
    }
    
    public static func readCard() -> UserCard?{
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "UserCard")
        fetchRequest.returnsObjectsAsFaults = false
        let card: UserCard = UserCard()
        do {
            
            let results = try context.executeFetchRequest(fetchRequest)
            if results.count > 0 {
                card.cardNumber = results[0].valueForKey("cardNumber") as! String
                card.expirationDate = results[0].valueForKey("expirationDate") as! String
                return card
            }
            return nil
        } catch {
            return nil
        }
    }
    
    public static func deleteAllTables() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        do{
        try deleteTable("User", context: context)
         try deleteTable("Service", context: context)
         try deleteTable("Car", context: context)
         try deleteTable("UserCard", context: context)
            
        } catch {
            
        }
    }

    public static var errorSavingData: ErrorType!
}
