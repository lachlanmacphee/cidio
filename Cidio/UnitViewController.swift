//
//  UnitViewController.swift
//  Cidio
//
//  Created by Lachlan MacPhee on 4/5/2023.
//

import UIKit

class UnitViewController: UIViewController {
    
    var unit: CidioUnit?
    var cdc: CoreDataController = CoreDataController()
    var appDelegate: AppDelegate!
    
    @IBOutlet weak var unitTitleLabel: UILabel!
    
    @IBOutlet weak var unitYearLabel: UILabel!
    
    @IBOutlet weak var unitFacultyLabel: UILabel!
    
    @IBOutlet weak var unitLocationLabel: UILabel!
    
    @IBOutlet weak var reminderDropdown: UIButton!
    
    @IBAction func saveUnitClicked(_ sender: Any) {
        if let unit, let unitName = unit.unitName, let unitCode = unit.id {
            cdc.createSavedUnit(unitName: unitName, unitCode: unitCode)
        }
    }

    @IBAction func viewAssessmentChartClicked(_ sender: Any) {
        performSegue(withIdentifier: "unitPageToAssessmentChart", sender: self)
    }

    @IBOutlet weak var reviewsTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate?
        
        // Set the corner radius and enable clipping to bounds for the reviews table view
        reviewsTable.layer.cornerRadius = 10
        reviewsTable.layer.masksToBounds = true
        
        setupReminderPullDownButton()
        
        if let unit {
            // Set the view controller's title to the unit code
            self.title = unit.id
            
            // Set the labels with the unit data
            unitTitleLabel.text = unit.unitName
            unitYearLabel.text = "Data from: \(unit.year ?? "N/A")"
            unitFacultyLabel.text = "Faculty: \(unit.faculty ?? "N/A")"
            unitLocationLabel.text = "Online or Hybrid: \(unit.location ?? "N/A")"
            
            reviewsTable.dataSource = self
            reviewsTable.delegate = self
            
            reviewsTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        }
    }

    
    // https://stackoverflow.com/questions/69877260/how-to-show-pull-down-button-menu-in-ios-14-swift
    // https://stackoverflow.com/questions/74428482/swift-why-does-pop-up-button-throw-nsinternalinconsistencyexception
    func setupReminderPullDownButton() {
        let optionClosure = { (action: UIAction) in
            var timeToWait: Double
            // Determine the time to wait based on the selected option's title
            switch action.title {
                case "10 seconds":
                    timeToWait = 10
                case "1 hour":
                    // 3600 seconds in 1 hour
                    timeToWait = 3600
                case "1 day":
                    // 86400 seconds in 1 day
                    timeToWait = 86400
                case "30 days":
                    // 2592000 seconds in 30 days
                    timeToWait = 2592000
                case "90 days":
                    // 7776000 seconds in 90 days
                    timeToWait = 7776000
                default:
                    // Default time to wait is 1 day
                    timeToWait = 86400
            }
            // Create a notification with the unit's ID and name using the selected time to wait
            if let unit = self.unit, let unitId = unit.id, let unitName = unit.unitName {
                self.appDelegate.createNotification(title: "Time to check \(unitId)", body: "This is a reminder to check for changes in \(unitName)", time: timeToWait)
            }
        }
        
        // Create a menu for the reminder dropdown button with actions for each option
        reminderDropdown.menu = UIMenu(children: [
            UIAction(title: "10 seconds", handler: optionClosure),
            UIAction(title: "1 hour", handler: optionClosure),
            UIAction(title: "1 day", handler: optionClosure),
            UIAction(title: "30 days", handler: optionClosure),
            UIAction(title: "90 days", handler: optionClosure),
        ])
        
        reminderDropdown.showsMenuAsPrimaryAction = true
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unitPageToAssessmentChart" {
            if let unitAssessmentsViewController = segue.destination as? UnitAssessmentsViewController {
                unitAssessmentsViewController.assessmentData = unit?.assessments
                unitAssessmentsViewController.classData = unit?.classes
            }
        }
    }

}

extension UnitViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let unit, let unitReviews = unit.reviews {
            return unitReviews.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        
        if let unit, let unitReviews = unit.reviews {
            content.text = unitReviews[indexPath.row].comment
            content.secondaryText = unitReviews[indexPath.row].from
        }
        
        cell.contentConfiguration = content
        
        return cell
    }
    
}

