//
//  SearchViewController.swift
//  Cidio
//
//  Created by Lachlan MacPhee on 10/4/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SearchViewController: UIViewController, FacultiesSelectedDelegate, UnitStaffSelectedDelegate {
    var handle: AuthStateDidChangeListenerHandle?
    var searchdb: Firestore?
    var selectedFaculties: [String] = []
    var selectedUnitStaff: [String] = []
    var selectedUnit: CidioUnit?
    var searchResults: [CidioUnit]?
    var cdc: CoreDataController = CoreDataController()
    var fbc: FirebaseController = FirebaseController()

    @IBOutlet weak var searchField: UITextField!
    
    @IBOutlet weak var yearField: UISegmentedControl!
    
    @IBOutlet weak var facultyField: UIButton!
    
    @IBOutlet weak var staffField: UIButton!
    
    @IBOutlet weak var locationField: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Make sure no segments are selected by default
        yearField.selectedSegmentIndex = UISegmentedControl.noSegment
        locationField.selectedSegmentIndex = UISegmentedControl.noSegment
    }
    
    
    @IBAction func facultyButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "searchToFacultySelection", sender: self)
    }
    
    
    @IBAction func unitStaffButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "searchToUnitStaffSelection", sender: self)
    }
    
    func showNoResultsAlert() {
        // Create an alert controller to display the no results message
        let alertController = UIAlertController(title: "No Results Found", message: "Please adjust your search parameters or double-check the unit code.", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func searchButtonClicked(_ sender: Any) {
        // If a unit code was entered, try searching by that first.
        if let searchTerm = searchField.text, !searchTerm.isEmpty {
            fbc.searchByUnitCode(unitCode: searchTerm) { unit in
                if let unit {
                    self.selectedUnit = unit
                    self.performSegue(withIdentifier: "searchToUnit", sender: self)
                } else {
                    print("Failed to retrieve CidioUnit object")
                }
            }
            return
        }
        
        // Otherwise, search by the filters
        
        // Get all non-empty parameters and make an array of key-value pairs
        var nonEmptyParams: [String: Any] = [:]
        
        // Check if a year is selected and add it to the parameters
        if yearField.selectedSegmentIndex != -1, let year = yearField.titleForSegment(at: yearField.selectedSegmentIndex) {
            nonEmptyParams["year"] = year
        }
        
        // Check if any faculties are selected and add them to the parameters
        if selectedFaculties.count > 0 {
            nonEmptyParams["faculty"] = selectedFaculties
        }
        
        // Check if any unit staff are selected and add them to the parameters
        if selectedUnitStaff.count > 0 {
            nonEmptyParams["staff"] = selectedUnitStaff
        }
        
        // Check if a location is selected and add it to the parameters
        if locationField.selectedSegmentIndex != -1, let location = locationField.titleForSegment(at: locationField.selectedSegmentIndex) {
            nonEmptyParams["location"] = location
        }
        
        // Perform a search with the provided parameters
        fbc.searchUnitByFilters(params: nonEmptyParams) { documents in
            if let documents {
                if documents.isEmpty {
                    // If no results are found, display the no results alert
                    self.showNoResultsAlert()
                } else {
                    // If results are found, store them in searchResults and perform the segue to the results view
                    self.searchResults = documents
                    self.performSegue(withIdentifier: "searchToResults", sender: self)
                }
            } else {
                print("Failed to retrieve array of CidioUnit objects")
            }
        }
        return
    }

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Prepare for different segues based on their identifiers
        
        if segue.identifier == "searchToUnitStaffSelection" {
            if let unitStaffSelectionViewController = segue.destination as? UnitStaffSelectionTableViewController {
                unitStaffSelectionViewController.delegate = self
            }
        }

        if segue.identifier == "searchToFacultySelection" {
            if let facultySelectionViewController = segue.destination as? FacultySelectionTableViewController {
                facultySelectionViewController.delegate = self
            }
        }
        
        if segue.identifier == "searchToUnit" {
            if let unitViewController = segue.destination as? UnitViewController {
                unitViewController.unit = selectedUnit
            }
        }
        
        if segue.identifier == "searchToResults" {
            if let searchResultsTableViewController = segue.destination as? SearchResultsTableViewController {
                if let searchResults {
                    searchResultsTableViewController.results = searchResults
                }
            }
        }
    }

    
    func userDidSelectFaculties(faculties: [String]) {
        if !faculties.isEmpty {
            // If faculties are selected, update the selectedFaculties array and set the button title
            selectedFaculties = faculties
            facultyField.setTitle(faculties.joined(separator: ", "), for: .normal)
        } else {
            // If no faculties are selected, reset the selectedFaculties array and set the default button title
            selectedFaculties = []
            facultyField.setTitle("Click to select a faculty", for: .normal)
        }
    }

    func userDidSelectUnitStaff(staff: [String]) {
        if !staff.isEmpty {
            // If unit staff are selected, update the selectedUnitStaff array and set the button title
            selectedUnitStaff = staff
            staffField.setTitle(staff.joined(separator: ", "), for: .normal)
        } else {
            // If no unit staff are selected, reset the selectedUnitStaff array and set the default button title
            selectedUnitStaff = []
            staffField.setTitle("Click to select unit staff", for: .normal)
        }
    }

}


// https://stackoverflow.com/questions/26076054/changing-placeholder-text-color-with-swift
extension UITextField {
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            // Getter for the placeHolderColor property
            return self.placeHolderColor
        }
        set {
            // Setter for the placeHolderColor property
            // Set the attributedPlaceholder with the specified placeholder text and text color
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "", attributes: [NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}

