//
//  ViewController.swift
//  Milestone: Projects 1-3
//
//  Created by Alexander Kazakov on 3/24/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

  var countries = [String]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "MILESTONE: PROJECT: 1-3"
    tableView.rowHeight = 100
    
    let fileManager = FileManager.default
    let bundlePath = Bundle.main.bundleURL
    let flagsImagesFolder = bundlePath.appendingPathComponent("FlagsImages")
    
    let items = try! fileManager.contentsOfDirectory(atPath: flagsImagesFolder.path)

    countries = items.filter { (item) -> Bool in
      return !item.contains("@")
    }
    
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return countries.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "FlagCell")!
    
    cell.imageView?.image = UIImage(named: countries[indexPath.row])
    cell.imageView?.layer.borderColor = UIColor.gray.cgColor
    cell.imageView?.layer.borderWidth = 1
    
    cell.textLabel?.text = countries[indexPath.row].split(separator: ".")[0].uppercased()
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as! DetailViewController
    vc.imageName = countries[indexPath.row]
    navigationController?.pushViewController(vc, animated: true)
    
  }
  
}
