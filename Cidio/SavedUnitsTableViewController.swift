//
//  SavedUnitsTableViewController.swift
//  Cidio
//
//  Created by Lachlan MacPhee on 2/5/2023.
//

import UIKit
import CoreData
import FirebaseAuth
import FirebaseFirestore

class SavedUnitsTableViewController: UITableViewController {
    
    var cdc: CoreDataController = CoreDataController()
    var fbc: FirebaseController = FirebaseController()
    var handle: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add an observer to listen for the "SavedUnitsDidChange" notification
        NotificationCenter.default.addObserver(self, selector: #selector(savedUnitsDidChange), name: Notification.Name("SavedUnitsDidChange"), object: nil)
    }
    
    deinit {
        // Remove the observer when the view controller is deallocated
        NotificationCenter.default.removeObserver(self, name: Notification.Name("SavedUnitsDidChange"), object: nil)
    }
    
    @objc func savedUnitsDidChange() {
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let unitsCount = cdc.fetchSavedUnitsCount()
        
        if unitsCount == 0 {
            // Show an empty message when there are no saved units
            self.tableView.setEmptyMessage("You have no saved units. Use the Search tab to find some units and then click the Save button.")
        } else {
            // Otherwise, restore the table view to its default state
            self.tableView.restore()
        }
        
        return unitsCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        let rowData = cdc.fetchSavedUnits()[indexPath.row]
        content.text = rowData.unitName
        content.secondaryText = rowData.unitCode
        cell.contentConfiguration = content
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let unitCodeToDelete = cdc.fetchSavedUnits()[indexPath.row].unitCode
            if let unitCodeToDelete {
                cdc.deleteSavedUnit(unitCode: unitCodeToDelete)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUnit = cdc.fetchSavedUnits()[indexPath.row]
        if let unitCode = selectedUnit.unitCode {
            // Search for the selected unit by its unit code
            fbc.searchByUnitCode(unitCode: unitCode) { unit in
                if let unit {
                    // If the unit is found, navigate to the UnitViewController to display the details
                    let unitVC = self.storyboard?.instantiateViewController(withIdentifier: "unitViewController") as? UnitViewController
                    unitVC?.unit = unit
                    self.navigationController?.pushViewController(unitVC!, animated: true)
                } else {
                    print("Failed to retrieve CidioUnit object")
                }
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

// The following code originates from a user of StackOverflow named Frankie
// The source of this code can be found here: https://stackoverflow.com/questions/15746745/handling-an-empty-uitableview-print-a-friendly-message
extension UITableView {
    func setEmptyMessage(_ message: String) {
        // Create a container view with the same size as the table view
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        
        // Create a label to display the empty message
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        containerView.addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add constraints to position the message label within the container view
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            messageLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            messageLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
        
        self.backgroundView = containerView
        self.separatorStyle = .none
    }
    
    func restore() {
        // Restore the table view to its default state by removing the background view and showing separators
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}


