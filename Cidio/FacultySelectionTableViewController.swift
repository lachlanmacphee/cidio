//
//  FacultySelectionTableViewController.swift
//  Cidio
//
//  Created by Lachlan MacPhee on 11/5/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

// Protocol for notifying when faculties are selected
protocol FacultiesSelectedDelegate: AnyObject {
    func userDidSelectFaculties(faculties: [String])
}

class FacultySelectionTableViewController: UITableViewController {
    
    var handle: AuthStateDidChangeListenerHandle?
    var faculties: [String]?
    weak var delegate: FacultiesSelectedDelegate? = nil
    var selectedFaculties: [String] = []
    var universityData: CidioUniversityData?
    var fbc: FirebaseController = FirebaseController()
    var selectedCells: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            self.fbc.fetchUniversityData() { data in
                if let data {
                    self.universityData = data
                    // Reload the table view on the main thread to reflect the updated data
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    print("Failed to retrieve University data")
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.userDidSelectFaculties(faculties: selectedFaculties)
        Auth.auth().removeStateDidChangeListener(handle!)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let faculties = universityData?.faculties {
            return faculties.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            // Create an image view with a square icon and set its frame size
            let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imgView.image = UIImage(systemName: "square")
        
            cell.accessoryView = imgView
            var content = cell.defaultContentConfiguration()
            
            if let faculties = universityData?.faculties {
                content.text = faculties[indexPath.row]
            }
            
            cell.contentConfiguration = content
            
            return cell
        }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if let faculties = universityData?.faculties {
                selectedFaculties.append(faculties[indexPath.row])
                
                guard let cell = tableView.cellForRow(at: indexPath) else {
                    return
                }
                
                // Create an image view with a checked square icon and set its frame size
                let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                imgView.image = UIImage(systemName: "checkmark.square.fill")
                
                cell.accessoryView = imgView
            }
        }

    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
            if let faculties = universityData?.faculties {
                // Filter the selectedFaculties array to remove the deselected faculty
                selectedFaculties = selectedFaculties.filter { faculty in
                    return faculty != faculties[indexPath.row]
                }
                
                guard let cell = tableView.cellForRow(at: indexPath) else {
                    return
                }
                
                // Create an image view with a square icon and set its frame size
                let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                imgView.image = UIImage(systemName: "square")
                
                cell.accessoryView = imgView
            }
        }

}
