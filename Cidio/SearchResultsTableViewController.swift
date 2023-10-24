//
//  SearchResultsTableViewController.swift
//  Cidio
//
//  Created by Lachlan MacPhee on 4/5/2023.
//

import UIKit
import FirebaseFirestoreSwift

class SearchResultsTableViewController: UITableViewController {
    
    var results: [CidioUnit] = []   // Array to store the search results
    var selectedUnit: CidioUnit?    // Variable to store the selected unit
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        let unit = results[indexPath.row]
        content.text = unit.unitName
        content.secondaryText = unit.id
        cell.contentConfiguration = content
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUnit = results[indexPath.row]
        performSegue(withIdentifier: "resultsToUnit", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "resultsToUnit" {
            if let unitViewController = segue.destination as? UnitViewController {
                unitViewController.unit = selectedUnit
            }
        }
    }
}

