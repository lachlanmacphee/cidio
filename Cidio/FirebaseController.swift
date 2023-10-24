//
//  FirebaseController.swift
//  Cidio
//
//  Created by Lachlan MacPhee on 11/5/2023.
//

import Foundation
import FirebaseFirestore

class FirebaseController {
    var cdc: CoreDataController = CoreDataController()
    var db: Firestore
    
    init() {
        db = Firestore.firestore()
    }

    func searchByUnitCode(unitCode: String, completion: @escaping (CidioUnit?) -> Void) {
        // Fetch the user's university from CoreData
        let userUni = cdc.fetchUserUniversity()
        
        // Create a Firestore query to retrieve the document with the specified unit code
        let unitQuery = db.collection(userUni).document(unitCode)
        
        // Get the document snapshot for the unit query
        unitQuery.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error getting document: \(error)")
                completion(nil)
            } else {
                guard let document = documentSnapshot else {
                    print("Document does not exist")
                    completion(nil)
                    return
                }
                do {
                    // Convert the document data to the CidioUnit object
                    let unit = try document.data(as: CidioUnit.self)
                    completion(unit)
                } catch {
                    print(error)
                    completion(nil)
                }
            }
        }
    }

    
    func searchUnitByFilters(params: Dictionary<String, Any>, completion: @escaping ([CidioUnit]?) -> Void) {
        
        // This code creates dynamic Firestore queries based on the fields a user has entered data in
        // It originates from a StackOverflow user named "trndjc": https://stackoverflow.com/questions/66899455/how-to-perform-dynamic-wherefield-in-firestore-queries
        func getQuery(from parameters: [String:Any]) -> Query? {
            var q: Query?
            
            // Iterate through the parameters to create the query
            for (n, p) in parameters.enumerated() {
                if n == 0 {
                    // This is the first iteration of the loop and so this is where we initialize the query object using the first parameter.
                    if p.value is Array<Any> {
                        // If the parameter value is an array, we handle it differently based on the key
                        if p.key == "faculty" {
                            // If the key is "faculty", we use the `whereField(_:in:)` method to check if the field contains any of the specified values
                            q = db.collection(cdc.fetchUserUniversity()).whereField(p.key, in: p.value as! [Any])
                        } else {
                            // For other keys, we use the `whereField(_:arrayContainsAny:)` method to check if the array field contains any of the specified values
                            q = db.collection(cdc.fetchUserUniversity()).whereField(p.key, arrayContainsAny: p.value as! [Any])
                        }
                    } else {
                        // If the parameter value is not an array, we use the `whereField(_:isEqualTo:)` method to check for exact equality
                        q = db.collection(cdc.fetchUserUniversity()).whereField(p.key, isEqualTo: p.value)
                    }
                } else {
                    // This is an additional iteration of the loop and so this is where we append the existing query object with the additional parameter.
                    if p.value is Array<Any> {
                        if p.key == "faculty" {
                            q = q?.whereField(p.key, in: p.value as! [Any])
                        } else {
                            q = q?.whereField(p.key, arrayContainsAny: p.value as! [Any])
                        }
                    } else {
                        q = q?.whereField(p.key, isEqualTo: p.value)
                    }
                }
            }
            
            return q
        }

        
        if let query = getQuery(from: params) {
            query.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error making query: \(error)")
                } else {
                    guard let query = querySnapshot else {
                        completion(nil)
                        return
                    }
                    
                    if query.documents.isEmpty {
                        completion([])
                        return
                    }
                    
                    var documents: [CidioUnit] = []
                    
                    // Iterate through the query documents
                    for document in query.documents {
                        do {
                            if document.documentID != "index" {
                                // Exclude the document with ID "index" from the results
                                // Attempt to parse the document data into a CidioUnit object
                                try documents.append(document.data(as: CidioUnit.self))
                            }
                        } catch {
                            print(error)
                        }
                    }
                    
                    completion(documents)
                }
            }
        }

    }
    
    func fetchUniversityData(completion: @escaping (CidioUniversityData?) -> Void) {
        let userUni = cdc.fetchUserUniversity()

        let uniDataQuery = db.collection(userUni).document("index")
        
        uniDataQuery.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error getting document: \(error)")
                completion(nil)
            } else {
                guard let document = documentSnapshot else {
                    print("Document does not exist")
                    completion(nil)
                    return
                }
                
                do {
                    // Parse the document data into a CidioUniversityData object
                    let data = try document.data(as: CidioUniversityData.self)
                    completion(data)
                } catch {
                    print(error)
                    completion(nil)
                }
            }
        }
    }

    
    func addUnitListener(unitCode: String) {
        let userUni = cdc.fetchUserUniversity()
        
        // Create a Firestore query to listen for changes in the specified unit document
        let query = db.collection(userUni).whereField(FieldPath.documentID(), isEqualTo: unitCode)
        
        // Add a snapshot listener to the query
        query.addSnapshotListener { [self] snapshot, error in
            guard let snapshot = snapshot else {
                print("Error fetching snapshot: \(error!)")
                return
            }
            
            // Process the document changes in the snapshot
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .modified) {
                    // If the document is modified, delete and create an alert for the unit
                    self.cdc.deleteAlert(alertTitle: "Update for \(unitCode)", alertMessage: "Some data was modified")
                    self.cdc.createAlert(alertTitle: "Update for \(unitCode)", alertMessage: "Some data was modified")
                }
                if (diff.type == .removed) {
                    // If the document is removed, delete and create an alert for the unit
                    self.cdc.deleteAlert(alertTitle: "Update for \(unitCode)", alertMessage: "Some data was removed")
                    self.cdc.createAlert(alertTitle: "Update for \(unitCode)", alertMessage: "Some data was removed")
                }
            }
        }
    }
}

