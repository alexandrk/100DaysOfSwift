//
//  SiteActionsTableViewController.swift
//  Extension
//
//  Created by Alexander Kazakov on 6/12/19.
//  Copyright © 2019 Dictality. All rights reserved.
//

import UIKit
import MobileCoreServices

class SiteActionsTableViewController: UITableViewController {

  private var scripts = [Script]() {
    didSet {
      tableView.reloadData()
    }
  }
  private var selectedIndexPath: IndexPath?
  var pageTitle: String!
  var hostName: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    parseExtensionParameters() { [weak self] in
      self?.scripts = DataManager.retreive(for: self!.hostName)
    }
    
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Scripts", style: .plain, target: self, action: #selector(showScripts))
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showScriptEditor))
  }

  override func viewDidAppear(_ animated: Bool) {
    scripts = DataManager.retreive(for: hostName)
    tableView.reloadData()
  }
  
  // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return scripts.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "scriptCell", for: indexPath)

    cell.textLabel?.text = scripts[indexPath.row].name
    cell.detailTextLabel?.text = "for: \(scripts[indexPath.row].hostName)"

    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    showScriptEditorWith(script: scripts[indexPath.row])
  }

  func parseExtensionParameters(completionHandler: @escaping () -> Void) {
    // Parse the parameters that were passed from the webpage through the extension to the here
    if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
      if let itemProvider = inputItem.attachments?.first {
        itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] (dict, error) in
          
          guard let itemDictionary = dict as? NSDictionary else { return }
          guard let javascriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
          self?.hostName = URL(string: javascriptValues["URL"] as? String ?? "")?.host ?? ""
          
          DispatchQueue.main.async {
            self?.title = self?.pageTitle
          }
          
          completionHandler()
        }
      }
    }
  }
  
  @objc func showScriptEditor() {
    let vc = storyboard?.instantiateViewController(withIdentifier: "ActionViewController") as! ActionViewController
    vc.hostName = hostName
    if let selectedIndexPath = selectedIndexPath {
      vc.script = scripts[selectedIndexPath.row]
    }
    navigationController?.pushViewController(vc, animated: true)
  }
  
  @objc func showScripts() {
    let ac = UIAlertController(title: "Select Script Type", message: nil, preferredStyle: .actionSheet)
    ac.addAction(UIAlertAction(title: "Default Scripts", style: .default) { [weak self] (_) in self?.showPredefinedScripts() })
    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    present(ac, animated: true)
  }
  
  @objc func showPredefinedScripts() {
    let scripts = DataManager.retreive(for: "default")
    
    // If Default Scripts are present in the UserDefaults, generate alert controller with item per script.
    if !scripts.isEmpty {
      let ac = UIAlertController(title: "Default Scripts", message: nil, preferredStyle: .actionSheet)
      for script in scripts {
        ac.addAction(UIAlertAction(title: script.name, style: .default) { [weak self] (_) in self?.showScriptEditorWith(script: script) })
      }
      ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
      present(ac, animated: true)
    } else {
      // Populate Default Scripts UserData and try again.
      populateDefaultScripts()
      showPredefinedScripts()
    }
  }
  
  func showScriptEditorWith(script: Script) {
    let vc = storyboard?.instantiateViewController(withIdentifier: "ActionViewController") as! ActionViewController
    vc.hostName = hostName
    vc.script = script
    navigationController?.pushViewController(vc, animated: true)
  }
  
  // Populates UserDefaults with default scripts available for all pages.
  func populateDefaultScripts() {
    let defaultScripts = [
      Script(hostName: "n/a", name: "Simple Alert", text: "alert('Hello World');"),
      Script(hostName: "n/a", name: "Show Web Page Title", text: "alert(document.title);")
    ]
    DataManager.save(data: defaultScripts, key: "default")
  }
  
}
