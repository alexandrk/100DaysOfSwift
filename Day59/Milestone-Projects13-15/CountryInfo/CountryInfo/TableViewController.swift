//
//  TableViewController.swift
//  CountryInfo
//
//  Created by Alexander Kazakov on 5/16/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

  var countries = [Country]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Country Information"
    
    guard let countriesJSON = Bundle.main.url(forResource: "countries", withExtension: "json") else { return }
    do {
      let data = try Data(contentsOf: countriesJSON)
      countries = try JSONDecoder().decode([Country].self, from: data)
      tableView.reloadData()
    } catch {
      print(error)
    }
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return countries.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell") else { return UITableViewCell() }
    
    cell.textLabel?.text = countries[indexPath.row].name
    cell.detailTextLabel?.text = "Capital: \(countries[indexPath.row].capital)"
    
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
    vc.country = countries[indexPath.row]
    
    navigationController?.pushViewController(vc, animated: true)
  }
  
}

