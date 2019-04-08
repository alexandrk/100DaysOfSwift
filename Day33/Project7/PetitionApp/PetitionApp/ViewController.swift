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
  // https://api.whitehouse.gov/v1/petitions.json?limit=100
  private let API_URL = "https://www.hackingwithswift.com/samples/petitions-1.json"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let url = URL(string: API_URL) {
      if let data = try? Data(contentsOf: url) {
        parse(json: data)
      }
    }
    
  }

  func parse(json: Data) {
    let decoder = JSONDecoder()
    
    do {
      let jsonPetitions = try decoder.decode(Petitions.self, from: json)
      petitions = jsonPetitions.results
      tableView.reloadData()
    } catch {
      print(error)
      let vc = UIAlertController(title: "ERROR", message: "Cannot parse json from: \(API_URL).", preferredStyle: .alert)
      vc.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
      present(vc, animated: true, completion: nil)
    }
    
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
  
}

