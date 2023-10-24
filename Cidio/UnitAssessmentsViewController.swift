//
//  UnitAssessmentsViewController.swift
//  Cidio
//
//  Created by Lachlan MacPhee on 18/5/2023.
//

import UIKit
import Charts

class UnitAssessmentsViewController: UIViewController {
    var assessmentData: [CidioUnitAssessment]?
    var classData: [CidioUnitClass]?
    
    @IBOutlet weak var assessmentChart: PieChartView!
    @IBOutlet weak var locationChart: ScatterChartView!
    
    var assessmentsDataEntries = [PieChartDataEntry]()
    var locationsDataEntries = [PieChartDataEntry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable legends for assessmentChart and locationChart
        assessmentChart.legend.enabled = false
        locationChart.legend.enabled = false
        
        if let assessmentData {
            for assessment in assessmentData {
                if let worth = assessment.worth, let name = assessment.name {
                    // Create a PieChartDataEntry for each assessment and add it to assessmentsDataEntries
                    let dataEntry = PieChartDataEntry(value: worth)
                    dataEntry.label = name
                    assessmentsDataEntries.append(dataEntry)
                }
            }
        }
        
        if let classData {
            var numClassesOnline: Double = 0
            var numClassesInPerson: Double = 0
            
            for unitClass in classData {
                if let locations = unitClass.locations {
                    if locations.contains("Online") {
                        numClassesOnline += 1
                    } else {
                        numClassesInPerson += 1
                    }
                }
            }
            
            // Create a PieChartDataEntry for the number of classes online and add it to locationsDataEntries
            let onlineDataEntry = PieChartDataEntry(value: numClassesOnline)
            onlineDataEntry.label = "Online"
            locationsDataEntries.append(onlineDataEntry)
            
            // Create a PieChartDataEntry for the number of classes in-person and add it to locationsDataEntries
            let inPersonDataEntry = PieChartDataEntry(value: numClassesInPerson)
            inPersonDataEntry.label = "In Person"
            locationsDataEntries.append(inPersonDataEntry)
        }
        
        updateLocationChartData()
        updateAssessmentChartData()
    }

    
    func updateAssessmentChartData() {
        // Create a PieChartDataSet with the assessmentsDataEntries and an empty label
        let chartDataSet = PieChartDataSet(entries: assessmentsDataEntries, label: "")
        let chartData = PieChartData(dataSet: chartDataSet)
        
        // Set the colors of the chartDataSet using the colorful color template
        chartDataSet.colors = ChartColorTemplates.colorful()
        
        // Assign the chartData to the assessmentChart
        assessmentChart.data = chartData
        
        // Create a NumberFormatter for displaying the values as percentages
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        
        // Set the value formatter of the chartData to format the values as percentages
        chartData.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
    }

    func updateLocationChartData() {
        // Create a PieChartDataSet with the locationsDataEntries and an empty label
        let chartDataSet = PieChartDataSet(entries: locationsDataEntries, label: "")
        let chartData = PieChartData(dataSet: chartDataSet)
        
        // Set the colors of the chartDataSet using the material color template
        chartDataSet.colors = ChartColorTemplates.material()
        
        // Assign the chartData to the locationChart
        locationChart.data = chartData
        
        // Create a NumberFormatter for displaying the values without decimal places
        let pFormatter = NumberFormatter()
        pFormatter.maximumFractionDigits = 0
        
        // Set the value formatter of the chartData to format the values without decimal places
        chartData.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
    }


}
