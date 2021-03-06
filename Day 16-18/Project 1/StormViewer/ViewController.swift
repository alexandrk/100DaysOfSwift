//
//  ViewController.swift
//  StormViewer
//
//  Created by Alexander Kazakov on 3/14/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

  var pictures = [String]()
  var counter = [String: Int]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Storm Viewer"
    navigationController?.navigationBar.prefersLargeTitles = true
    
    // Add Recommend button to nav bar
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Recommend to others", style: .plain, target: self, action: #selector(recommendAppPopover))
    
    loadData()
  }

  func loadData() {
    DispatchQueue.global(qos: .background).async { [weak self] in
      let fm = FileManager.default
      let path = Bundle.main.resourceURL!
      let items = try! fm.contentsOfDirectory(atPath: path.path)
      
      for item in items.sorted() {
        if item.hasPrefix("nssl") {
          // this is a picture to load!
          self?.pictures.append(item)
        }
      }
      
      // Load view counter from UserDefaults
      if let savedCounter = UserDefaults.standard.object(forKey: "counter") as? [String: Int] {
        self?.counter = savedCounter
      }
      
      DispatchQueue.main.async { [weak self] in
        self?.tableView.reloadData()
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return pictures.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
    
    cell.imageView?.image = image(UIImage(named: pictures[indexPath.row], in: Bundle.main, compatibleWith: nil)!, withSize: CGSize(width: 50, height: 50))
    
    cell.textLabel?.text = pictures[indexPath.row]
    cell.detailTextLabel?.text = "Number of views: \(counter[pictures[indexPath.row]] ?? 0)"
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if let detailViewController = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
      detailViewController.selectedImage = pictures[indexPath.row]
      detailViewController.navBarTitle = "Picture \(indexPath.row + 1) of \(pictures.count)"
      
      // Add to count of views for a given picture
      counter[pictures[indexPath.row]] = (counter[pictures[indexPath.row]] ?? 0) + 1
      tableView.reloadRows(at: [indexPath], with: .none)
      save()
      
      navigationController?.pushViewController(detailViewController, animated: true)
    }
    
  }
  
  func image( _ image: UIImage, withSize newSize: CGSize) -> UIImage {
    UIGraphicsBeginImageContext(newSize)
    image.draw(in: CGRect(x: 0,y: 0,width: newSize.width,height: newSize.height))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!.withRenderingMode(.automatic)
  }

  @objc func recommendAppPopover() {
    
    // Get the application name from Info.plist file, default to hardcoded string if not found
    var applicationName: String!
    if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
       let resorceFileDictionary = NSDictionary(contentsOfFile: path),
       let appNameFromPlist = resorceFileDictionary.object(forKey: "CFBundleDisplayName") as? String {
      applicationName = appNameFromPlist
    } else {
      applicationName = "StormViewer"
    }
    
    let vc = UIActivityViewController(activityItems: ["Check out this cool app that I'm using: '\(applicationName!)'."], applicationActivities: nil)
    vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
    present(vc, animated: true, completion: nil)
  }
  
  func save() {
    let userDefaults = UserDefaults.standard
    userDefaults.set(counter, forKey: "counter")
  }
  
}

