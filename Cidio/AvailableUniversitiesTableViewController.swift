//
//  AvailableUniversitiesTableViewController.swift
//  Cidio
//
//  Created by Lachlan MacPhee on 18/5/2023.
//

import UIKit

struct University: Decodable {
    let name: String
}

// Delegate protocol for notifying the selection of a university
protocol UniversitySelectedDelegate: AnyObject {
    func userDidSelectUniversity(university: String)
}

// https://cocoacasts.com/networking-fundamentals-how-to-make-an-http-request-in-swift
func fetchAvailableUniversities(completion: @escaping ([String]) -> Void) {
    // The API only supports HTTP. A change was made in info.plist to allow this
    guard let universityApiURL = URL(string: "http://universities.hipolabs.com/search?country=australia") else {
        print("Invalid URL")
        completion([])
        return
    }

    var universityNameList: [String] = []
    
    // Create a URLSession task to get Australian University names, remove duplicates, and sort them alphabetically
    // Combined with completion handlers, this allows the AvailableUniversities to be up to date each time it's opened
    let task = URLSession.shared.dataTask(with: universityApiURL) { data, response, error in
        if let data = data {
            do {
                let universities = try JSONDecoder().decode([University].self, from: data)
                universityNameList = Array(Set(universities.compactMap { $0.name })).sorted()
                completion(universityNameList)
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                completion([])
            }
        } else if let error = error {
            print("HTTP Request Failed: \(error.localizedDescription)")
            completion([])
        }
    }

    // Start the data task
    task.resume()
}

class AvailableUniversitiesTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    let searchController = UISearchController(searchResultsController: nil)
    var universities: [String] = []
    var filteredUniversities: [String] = [] // Array to hold filtered universities
    var selectedUniversity: String = "" // Currently selected university
    weak var delegate: UniversitySelectedDelegate? = nil // Delegate for university selection

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = true
        
        fetchAvailableUniversities { universityNames in
            DispatchQueue.main.async {
                // Update the array and reload the table view
                self.universities = universityNames
                self.filteredUniversities = universityNames
                self.tableView.reloadData()
            }
        }
        
        // Set up the search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Enter University name"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.userDidSelectUniversity(university: selectedUniversity)
        // Notify the delegate that a university has been selected before the view disappears
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUniversities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = filteredUniversities[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUniversity = filteredUniversities[indexPath.row]
        navigationController?.popViewController(animated: true)
        // Set the selected university and pop the view controller from the navigation stack
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            filteredUniversities = universities
            tableView.reloadData()
            return
        }
        
        filteredUniversities = universities.filter { item in
            return item.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
        // Filter the universities based on the search text and reload the table view data
    }
}
