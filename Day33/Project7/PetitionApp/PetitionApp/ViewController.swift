//
//  ViewController.swift
//  Project7_PetitionApp
//
//  Created by Alexander Kazakov on 4/7/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
  
  var petitions = [Petition]()
  var filteredPetitions = [Petition]()
  var searchController = UISearchController()
  var searchFooter: SearchFooter!
  var API_URL: String!
  var isFiltering: Bool {
    return !isSearchFieldEmpty() && searchController.isActive
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
   
    searchController                = setupSearchController()
    searchFooter                    = SearchFooter(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: 50)))
    navigationItem.searchController = searchController
    tableView.tableFooterView       = searchFooter
    
    // By setting definesPresentationContext on your view controller to true, you ensure that the search bar does not remain on the screen if the user navigates to another view controller while the UISearchController is active.
    definesPresentationContext = true
    
    if (navigationController?.tabBarItem.tag) == 0 {
      // https://api.whitehouse.gov/v1/petitions.json?limit=100
      API_URL = "https://www.hackingwithswift.com/samples/petitions-1.json"
      title = "MOST RECENT"
    } else {
      // https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100
      API_URL = "https://www.hackingwithswift.com/samples/petitions-2.json"
      title = "TOP RATED"
    }
    
    if let url = URL(string: API_URL) {
      if let data = try? Data(contentsOf: url) {
        parse(json: data)
      }
    }
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredits))
    
  }
  
  func setupSearchController() -> UISearchController {
    let controller = UISearchController(searchResultsController: nil)
    controller.searchResultsUpdater = self
    controller.obscuresBackgroundDuringPresentation = false
    controller.searchBar.placeholder = "Search Petitions"
    return controller
  }
  
  @objc func showCredits() {
    let vc = UIAlertController(title: "CREDITS", message: "This application uses the public API of the White House, located at: https://petitions.whitehouse.gov/developers", preferredStyle: .alert)
    vc.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    present(vc, animated: true, completion: nil)
  }
  
  func parse(json: Data) {
    let decoder = JSONDecoder()
    
    do {
      let jsonPetitions = try decoder.decode(Petitions.self, from: json)
      petitions = jsonPetitions.results
      tableView.reloadData()
    } catch {
      print(error)
      showError(title: "ERROR", message: "Cannot parse json from: \(API_URL!).")
    }
    
  }
  
  func showError(title: String?, message: String?) {
    let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
    vc.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    present(vc, animated: true, completion: nil)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isFiltering {
      searchFooter.setIsFilteringToShow(filteredItemCount: filteredPetitions.count, of: petitions.count)
      return filteredPetitions.count
    } else {
      return petitions.count
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    let petition = (isFiltering) ? filteredPetitions[indexPath.row] : petitions[indexPath.row]
    
    cell.textLabel?.text = petition.title
    cell.detailTextLabel?.text = petition.body
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = DetailViewController()
    vc.detailItem = petitions[indexPath.row]
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func isSearchFieldEmpty() -> Bool {
    return searchController.searchBar.text?.isEmpty ?? true
  }
  
}

extension ViewController: UISearchResultsUpdating {
  
  func updateSearchResults(for searchController: UISearchController) {
    filteredPetitions.removeAll(keepingCapacity: false)
    guard let searchQuery = searchController.searchBar.text?.lowercased() else { return }
    
    filteredPetitions = petitions.filter { (petition) -> Bool in
      return (petition.title.lowercased().contains(searchQuery) || petition.body.lowercased().contains(searchQuery))
    }
    
    tableView.reloadData()
  }
  
}
