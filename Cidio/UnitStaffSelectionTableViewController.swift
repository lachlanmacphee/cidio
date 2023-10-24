//
//  UnitStaffSelectionTableViewController.swift
//  Cidio
//
//  Created by Lachlan MacPhee on 11/5/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol UnitStaffSelectedDelegate: AnyObject {
    func userDidSelectUnitStaff(staff: [String])
}

class UnitStaffSelectionTableViewController: UITableViewController {
    
    var handle: AuthStateDidChangeListenerHandle?
    var staff: [String]?
    weak var delegate: UnitStaffSelectedDelegate? = nil
    var selectedStaff: [String] = []
    var universityData: CidioUniversityData?
    var fbc: FirebaseController = FirebaseController()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = true
    }

    
    override func viewWillAppear(_ animated: Bool) {
        self.fbc.fetchUniversityData() { data in
            if let data {
                self.universityData = data
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                print("Failed to retrieve University data")
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        delegate?.userDidSelectUnitStaff(staff: selectedStaff)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let staff = universityData?.staff {
            return staff.count
        }
        return 0
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Create an image view and set it as the accessory view of the cell
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imgView.image = UIImage(systemName: "square")
        cell.accessoryView = imgView
        
        var content = cell.defaultContentConfiguration()
        if let staff = universityData?.staff {
            content.text = staff[indexPath.row]
        }
        cell.contentConfiguration = content
        
        return cell
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let staff = universityData?.staff {
            selectedStaff.append(staff[indexPath.row])
            
            guard let cell = tableView.cellForRow(at: indexPath) else {
                return
            }
            
            // Create an image view with a checkmark square filled icon
            let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imgView.image = UIImage(systemName: "checkmark.square.fill")
            
            cell.accessoryView = imgView
        }
    }

    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let staff = universityData?.staff {
            // Filter the selectedStaff array to remove the deselected staff
            selectedStaff = selectedStaff.filter { staffMember in
                return staffMember != staff[indexPath.row]
            }
            
            guard let cell = tableView.cellForRow(at: indexPath) else {
                return
            }
            
            // Create an image view with a square icon
            let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imgView.image = UIImage(systemName: "square")
            
            cell.accessoryView = imgView
        }
    }

}
