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
    
    public static func newUser()->User{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        return User(entity: entity!, insertInto: context)
    }
    
    public static func newService()->Service{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "Service", in: context)
        return Service(entity: entity!, insertInto: context)
    }
    
    public static func newCar()->Car{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "Car", in: context)
        return Car(entity: entity!, insertInto: context)
    }
    
    public static func newUserCard()->UserCard{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "UserCard", in: context)
        return UserCard(entity: entity!, insertInto: context)
    }
    
    public static func save(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        do {
            try context.save()
        } catch {
            print("Error saving context")
        }
    }
    
    public static func deleteTable(table:String, context: NSManagedObjectContext) throws{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: table)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do{
            try context.execute(deleteRequest)
        } catch{
            throw errorSavingData
        }
    }
    
    public static func readUser() -> User?{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetchRequest) as! [User]
            if results.count > 0 {
                return results[0]
            }
            return nil
        } catch {
            return nil
        }
    }
    
    public static func readCars() -> [Car]{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Car")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            return try context.fetch(fetchRequest) as! [Car]
        } catch {
            return []
        }
    }
    
    public static func getFavoriteCar() -> Car?{
        let cars = readCars()
        for car in cars {
            if car.favorite {
                return car
            }
        }
        return nil
    }
    
    
    public static func setFavoriteCar(id: String) {
        let cars = readCars()
        var carsToSave = [Car]()
        for car in cars {
            car.favorite = false
            if car.id == id {
                car.favorite = true
            }
            carsToSave.append(car)
        }
    }
    
    public static func deleteCar(car:Car){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        context.delete(car)
    }
    
    public static func readService(id:String)->Service?{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Service")
        fetchRequest.returnsObjectsAsFaults = false
        let idPredicate = NSPredicate(format: "id = '%@'", id)
        fetchRequest.predicate = idPredicate
        do {
            let results = try context.fetch(fetchRequest) as! [Service]
            if results.count == 1 {
                return results[0]
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    
    public static func deleteService(service:Service){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        context.delete(service)
    }
    
    public static func getActiveService() -> Service?{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Service")
        fetchRequest.returnsObjectsAsFaults = false
        let statusPredicate = NSPredicate(format: "status != %@", "Canceled")
        let ratingPredicate = NSPredicate(format: "rating == %i", -1)
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [statusPredicate, ratingPredicate])
        do {
            let services = try context.fetch(fetchRequest) as! [Service]
            if  services.count > 0 {
                return services[0]
            }
            return nil
        } catch {
            return nil
        }
    }
    
    public static func getFinishedServices() -> [Service]{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Service")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "acceptedTime", ascending: false)]
        let statusPredicate = NSPredicate(format: "status = '%@'", "Finished")
        let ratingPredicate = NSPredicate(format: "rating != %i", -1)
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [statusPredicate, ratingPredicate])
        do {
            return try context.fetch(fetchRequest) as! [Service]
        } catch {
            return []
        }
    }
    
    public static func readCard() -> UserCard?{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserCard")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let cards = try context.fetch(fetchRequest) as! [UserCard]
            if cards.count > 0 {
                return cards[0]
            }
            return nil
        } catch {
            return nil
        }
    }
    
    public static func deleteCard(card:UserCard){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        context.delete(card)
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
            print("Error deleting tables")
        }
    }

    public static var errorSavingData: Error!
}
