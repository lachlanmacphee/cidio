//
//  AppDelegate.swift
//  Cidio
//
//  Created by Lachlan MacPhee on 10/4/2023.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure() // Configure Firebase services
        
        Auth.auth().signInAnonymously { authResult, error in
            // Sign in the user anonymously
        }
        
        let cdc = CoreDataController()
        let fbc = FirebaseController()
        
        for unit in cdc.fetchSavedUnits() {
            // Fetch all saved units from Core Data
            if let savedUnitCode = unit.unitCode {
                fbc.addUnitListener(unitCode: savedUnitCode)
                // Add a Firebase listener for the unit with the specified unit code to create alerts when app is open and changes are made
            }
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Cidio")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                print("Unresolved error \(error)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext // Get the managed object context from the persistent container
        
        if context.hasChanges {
            do {
                try context.save() // Save any changes made in the context to persistent storage
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror)") // Print the error if saving the context fails
            }
        }
        
        NotificationCenter.default.post(name: Notification.Name("SavedUnitsDidChange"), object: nil)
        // Post a notification named "SavedUnitsDidChange" to notify observers of changes related to saved units
        
        NotificationCenter.default.post(name: Notification.Name("AlertsDidChange"), object: nil)
        // Post a notification named "AlertsDidChange" to notify observers of changes related to alerts
    }

    
    // MARK: - Notifications
    func createNotification(title: String, body: String, time: Double) {
        let content = UNMutableNotificationContent()
        
        // Request authorisation to display notifications with alert, badge, and sound options
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (_, error) in
            if (error != nil) {
                print("Error requesting notification auth.")
            }
        }
        
        content.title = title // Set the title of the notification content
        content.body = body // Set the body of the notification content
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (time), repeats: false)
        // Create a time-based trigger for the notification with the specified time interval
        
        let uuidString = UUID().uuidString // Generate a unique identifier for the notification request
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        // Create a notification request with the unique identifier, notification content, and trigger
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.add(request) { (error) in
            if error != nil {
                print("Error creating notification.")
            }
        }
        // Add the notification request to the notification center to schedule the notification
    }


}

