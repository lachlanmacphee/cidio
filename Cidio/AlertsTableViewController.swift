//
//  AlertsTableViewController.swift
//  Cidio
//
//  Created by Lachlan MacPhee on 13/5/2023.
//

import UIKit

class AlertsTableViewController: UITableViewController {
    
    var cdc: CoreDataController = CoreDataController()
    var alerts = [Alert]() // Array to store the fetched alerts from Core Data

    override func viewDidLoad() {
        super.viewDidLoad()
        alerts = cdc.fetchAlerts() // Fetch the alerts from Core Data and populate the alerts array
        NotificationCenter.default.addObserver(self, selector: #selector(alertsDidChange), name: Notification.Name("AlertsDidChange"), object: nil) // Register observer to listen for "AlertsDidChange" notification
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("AlertsDidChange"), object: nil) // Remove observer when the view controller is deallocated
    }
    
    @objc func alertsDidChange() {
        alerts = cdc.fetchAlerts() // Update the alerts array with the latest alerts from Core Data
        tableView.reloadData() // Reload the table view to reflect the changes
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // Only one section in the table view
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let alertsCount = alerts.count
        
        if alertsCount == 0 {
            self.tableView.setEmptyMessage("You have no alerts. Save some units to receive alerts when they are changed.") // Show a message when there are no alerts
        } else {
            self.tableView.restore() // Restore the original appearance when there are alerts
        }
        
        return alertsCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let rowData = alerts[indexPath.row] // Get the alert data for the current row
        content.text = rowData.alertTitle // Set the alert title as the cell's primary text
        content.secondaryText = rowData.alertMessage // Set the alert message as the cell's secondary text
        cell.contentConfiguration = content
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true // Allow all alerts to be deleted and edited
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let title = alerts[indexPath.row].alertTitle, let message = alerts[indexPath.row].alertMessage {
                cdc.deleteAlert(alertTitle: title, alertMessage: message) // Delete the corresponding alert from Core Data using the title and message as predicates
            }
        }
    }
}
