//
//  ViewController.swift
//  ShoppingList
//
//  Created by Alexander Kazakov on 4/3/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

  var shoppingList = [String]()
  var shareToolbarButton: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Shopping Buddy"
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItemAction))
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear", style: .done, target: self, action: #selector(clearList))
    shareToolbarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareList))
      
    toolbarItems = [
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      shareToolbarButton
    ]
    navigationController?.isToolbarHidden = false
  }

  @objc func addItemAction() {
    let ac = UIAlertController(title: "Enter item to add to the list", message: nil, preferredStyle: .alert)
    
    ac.addTextField()
    
    let submitButton = UIAlertAction(title: "Add", style: .default) { [weak self, ac] (action) in
      guard let item = ac.textFields?[0].text else { return }
      self?.addItemToList(item)
    }
    ac.addAction(submitButton)
    present(ac, animated: true, completion: nil)
  }

  func addItemToList(_ item: String) {
    
    // Return without action if item is empty
    guard !item.isEmpty else { return }
    
    // Show message if item is already in the list
    for itemInList in shoppingList {
      if item.lowercased() == itemInList.lowercased() {
        let ac = UIAlertController(title: "DUPLICATE ITEM!", message: "Can't add duplicate items.", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
        return
      }
    }
    
    shoppingList.insert(item, at: 0)
    let indexPath = IndexPath(row: 0, section: 0)
    tableView.insertRows(at: [indexPath], with: .automatic)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return shoppingList.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListCell")
    cell?.textLabel?.text = shoppingList[indexPath.row]
    return cell!
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      shoppingList.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .automatic)
    }
  }
  
  @objc func clearList() {
    shoppingList.removeAll()
    tableView.reloadData()
  }
  
  @objc func shareList() {
    let activityVC = UIActivityViewController(activityItems: [shoppingList.joined(separator: "\n")], applicationActivities: nil)
    activityVC.popoverPresentationController?.barButtonItem = shareToolbarButton
    present(activityVC, animated: true)
  }
  
}

