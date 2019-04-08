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
  private var API_URL: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if navigationController?.tabBarItem.tag == 0 {
      // urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
      API_URL = "https://www.hackingwithswift.com/samples/petitions-1.json"
      title = "MOST RECENT"
    } else {
      // urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
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
    return petitions.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    let petition = petitions[indexPath.row]
    
    cell.textLabel?.text = petition.title
    cell.detailTextLabel?.text = petition.body
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = DetailViewController()
    vc.detailItem = petitions[indexPath.row]
    navigationController?.pushViewController(vc, animated: true)
  }
  
}

