//
//  CoreDataController.swift
//  Cidio
//
//  Created by Lachlan MacPhee on 2/5/2023.
//

import Foundation
import CoreData
import UIKit

class CoreDataController {
    var appDelegate: AppDelegate! // Reference to the AppDelegate
    var context: NSManagedObjectContext! // Managed object context for CoreData operations
    
    init() {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate? // Get reference to the AppDelegate
        self.context = appDelegate.persistentContainer.viewContext // Get the managed object context from the AppDelegate
    }
    
    func fetchSavedUnitsCount() -> Int {
        let request = NSFetchRequest<SavedUnit>(entityName: "SavedUnit")
        
        do {
            let results = try context.fetch(request)
            return results.count
        } catch {
            print("Error fetching saved units: \(error)")
        }
        
        return 0
    }
    
    func fetchSavedUnits() -> [SavedUnit] {
        let request = NSFetchRequest<SavedUnit>(entityName: "SavedUnit")
        
        do {
            let results = try context.fetch(request)
            return results.reversed() // Show most recent saved unit at the top
        } catch {
            print("Error fetching saved units: \(error)")
        }
        
        return []
    }
    
    func createSavedUnit(unitName: String, unitCode: String) {
        let fetchRequest: NSFetchRequest<SavedUnit> = SavedUnit.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "unitCode == %@", unitCode) // Predicate uses the unitCode to find units
        
        do {
            let results = try context.fetch(fetchRequest)
            guard results.isEmpty else {
                print("A SavedUnit with that unitCode already exists.")
                return
            }
            
            let entity = NSEntityDescription.entity(forEntityName: "SavedUnit", in: context)!
            let savedUnit = NSManagedObject(entity: entity, insertInto: context)
            
            savedUnit.setValue(unitName, forKeyPath: "unitName")
            savedUnit.setValue(unitCode, forKeyPath: "unitCode")
            
            appDelegate.saveContext()
            
        } catch let error as NSError {
            print("Error fetching saved units: \(error), \(error.userInfo)")
        }
    }
    
    func deleteSavedUnit(unitCode: String) {
        let fetchRequest: NSFetchRequest<SavedUnit> = SavedUnit.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "unitCode == %@", unitCode)  // Predicate uses the unitCode to find units
        
        do {
            let results = try context.fetch(fetchRequest)
            for savedUnit in results {
                context.delete(savedUnit)
            }
            
            appDelegate.saveContext()
            
        } catch let error as NSError {
            print("Error deleting saved unit: \(error), \(error.userInfo)")
        }
    }
    
    func fetchUserDetails() -> [String:String] {
        let request = NSFetchRequest<User>(entityName: "User")
        
        do {
            if let result = try context.fetch(request).first {
                if let fullName = result.value(forKey: "fullName") as? String,
                   let selectedUni = result.value(forKey: "selectedUniversity") as? String,
                   let email = result.value(forKey: "email") as? String,
                   let number = result.value(forKey: "number") as? String,
                   let bio = result.value(forKey: "bio") as? String {
                    return ["fullName": fullName, "selectedUni": selectedUni, "email": email, "number": number, "bio": bio]
                }
            } else {
                print("No user has been created yet")
            }
        } catch {
            print("Error fetching user details: \(error)")
        }
        
        return [:]
    }
    
    func fetchUserUniversity() -> String {
        let request = NSFetchRequest<User>(entityName: "User")
        
        do {
            if let result = try context.fetch(request).first {
                if let selectedUni = result.value(forKey: "selectedUniversity") as? String {
                    return selectedUni
                }
            } else {
                print("No University was found")
            }
        } catch {
            print("Error fetching user's University: \(error)")
        }
        
        return ""
    }
    
    func updateUserDetails(fullName: String, email: String, number: String, bio: String, uni: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let results = try? context.fetch(request)
        
        if results?.count == 0 {
            // Create a new user entity if none exists
            let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
            let newUser = NSManagedObject(entity: entity!, insertInto: context)
            newUser.setValue(fullName, forKey: "fullName")
            newUser.setValue(email, forKey: "email")
            newUser.setValue(number, forKey: "number")
            newUser.setValue(bio, forKey: "bio")
            newUser.setValue(uni, forKey: "selectedUniversity")
        } else {
            // Update the existing user entity
            let currentUser = results?.first as! NSManagedObject
            currentUser.setValue(fullName, forKey: "fullName")
            currentUser.setValue(email, forKey: "email")
            currentUser.setValue(number, forKey: "number")
            currentUser.setValue(bio, forKey: "bio")
            currentUser.setValue(uni, forKey: "selectedUniversity")
        }
        
        appDelegate.saveContext()
    }
    
    func fetchAlerts() -> [Alert] {
        let request = NSFetchRequest<Alert>(entityName: "Alert")
        
        do {
            let results = try context.fetch(request)
            return results.reversed() // Show the most recent alert at the top
        } catch {
            print("Error fetching alerts: \(error)")
        }
        
        return []
    }
    
    func createAlert(alertTitle: String, alertMessage: String) {
        let entity = NSEntityDescription.entity(forEntityName: "Alert", in: context)!
        let alert = NSManagedObject(entity: entity, insertInto: context)
        
        alert.setValue(alertTitle, forKeyPath: "alertTitle")
        alert.setValue(alertMessage, forKeyPath: "alertMessage")
        
        appDelegate.saveContext()
    }
    
    func deleteAlert(alertTitle: String, alertMessage: String) {
        let fetchRequest: NSFetchRequest<Alert> = Alert.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "alertTitle == %@ AND alertMessage == %@", argumentArray: [alertTitle, alertMessage])
        // Predicate matches both alertTitle and alertMessage
        
        do {
            let results = try context.fetch(fetchRequest)
            for alert in results {
                context.delete(alert)
            }
            
            appDelegate.saveContext()
            
        } catch let error as NSError {
            print("Error deleting alert: \(error), \(error.userInfo)")
        }
    }
}


