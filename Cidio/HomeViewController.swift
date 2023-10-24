//
//  HomeViewController.swift
//  Cidio
//
//  Created by Lachlan MacPhee on 10/4/2023.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    var cdc: CoreDataController = CoreDataController()
    @IBOutlet weak var savedUnitsShowAllButton: UIButton!
    @IBOutlet weak var updatesView: UIView!
    @IBOutlet weak var unitsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set corner radius and enable clipping for the updates view
        updatesView.layer.cornerRadius = 10
        updatesView.layer.masksToBounds = true
        
        // Set corner radius and enable clipping for the units view
        unitsView.layer.cornerRadius = 10
        unitsView.layer.masksToBounds = true
        
        // Register for the "SavedUnitsDidChange" notification
        NotificationCenter.default.addObserver(self, selector: #selector(savedUnitsDidChange), name: Notification.Name("SavedUnitsDidChange"), object: nil)
    }
    
    deinit {
        // Unregister from the "SavedUnitsDidChange" notification
        NotificationCenter.default.removeObserver(self, name: Notification.Name("SavedUnitsDidChange"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Check if there are any saved units and hide/show the "Show All" button accordingly
        if cdc.fetchSavedUnitsCount() == 0 {
            savedUnitsShowAllButton.isHidden = true
        } else {
            savedUnitsShowAllButton.isHidden = false
        }
    }
    
    @objc func savedUnitsDidChange() {
        // Called when the "SavedUnitsDidChange" notification is received
        
        // Check if there are any saved units and hide/show the "Show All" button accordingly
        if cdc.fetchSavedUnitsCount() == 0 {
            savedUnitsShowAllButton.isHidden = true
        } else {
            savedUnitsShowAllButton.isHidden = false
        }
    }
}

