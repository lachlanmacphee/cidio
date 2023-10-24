//
//  SettingsViewController.swift
//  Cidio
//
//  Created by Lachlan MacPhee on 10/4/2023.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController, UniversitySelectedDelegate {
    
    var cdc: CoreDataController = CoreDataController()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var uniButton: UIButton!
    @IBOutlet weak var bioTextField: UITextField!
    
    @IBAction func uniButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "settingsToAvailableUniversities", sender: self)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        // Update the user details in the CoreDataController using the values from the text fields and uniButton
        cdc.updateUserDetails(fullName: nameTextField.text ?? "", email: emailTextField.text ?? "", number: numberTextField.text ?? "", bio: bioTextField.text ?? "", uni: uniButton.currentTitle ?? "" )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillUserDetails()
    }
    
    func fillUserDetails() {
        let results = cdc.fetchUserDetails()
        if !results.isEmpty {
            // If the fetched results are not empty, fill the text fields and uniButton with the corresponding values
            nameTextField.text = results["fullName"] ?? ""
            emailTextField.text = results["email"] ?? ""
            numberTextField.text = results["number"] ?? ""
            uniButton.setTitle(results["selectedUni"] ?? "", for: .normal)
            bioTextField.text = results["bio"] ?? ""
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsToAvailableUniversities" {
            if let availableUnisViewController = segue.destination as? AvailableUniversitiesTableViewController {
                availableUnisViewController.delegate = self
            }
        }
    }
    
    func userDidSelectUniversity(university: String) {
        if !university.isEmpty {
            // If a university is selected, update the title of the uniButton with the selected university
            uniButton.setTitle(university, for: .normal)
        }
    }

}

