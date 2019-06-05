//
//  ActionViewController.swift
//  Extension
//
//  Created by Alexander on 6/4/19.
//  Copyright © 2019 Dictality. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

  @IBOutlet weak var scriptField: UITextView!
  var script: Script?
  var hostName: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    title = script?.name ?? "New Script"
    
    navigationItem.rightBarButtonItems = [
      UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveScript)),
      UIBarButtonItem(title: "Run", style: .done, target: self, action: #selector(runScript))
    ]
    
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard),
                                   name: UIResponder.keyboardWillHideNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard),
                                   name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    
    if let script = script {
      scriptField.text = script.text
    }
  }
  
  @objc func adjustForKeyboard(notifcation: Notification) {
    guard let keyboardValue = notifcation.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
    
    let keyboardScreenEndFrame = keyboardValue.cgRectValue
    
    // Here for edge cases, when the keyboard doesn't properly adjust when the phone is rotated horizontally
    let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
    
    if notifcation.name == UIResponder.keyboardWillHideNotification {
      scriptField.contentInset = .zero
    } else {
      scriptField.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
    }
    
    // Adjusts the scroll indicator bottom edge properly for when the keyboard is showed (coving the UITextView)
    scriptField.scrollIndicatorInsets = scriptField.contentInset
    
    let selectedRange = scriptField.selectedRange
    scriptField.scrollRangeToVisible(selectedRange)
  }
  
  /// Event Handler for the navigation bar button items
  
  @IBAction func saveScript() {
    let ac = UIAlertController(title: "Please Enter Script Name", message: nil, preferredStyle: .alert)
    ac.addTextField()
    ac.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak ac, weak self] (_) in
      guard let ac = ac,
        let self = self,
        let scriptName = ac.textFields?[0].text,
        let hostName = self.hostName else { return
      }
      // 1. Get saved scripts array
      var savedScripts = DataManager.retreive(for: hostName)
      // 2. Append to it the newly saved script
      savedScripts.append(Script(hostName: hostName, name: scriptName, text: self.scriptField.text))
      // 3. Save new array to UserDefaults
      DataManager.save(data: savedScripts, key: hostName)
      
      // 4. Go back to tableView
      self.navigationController?.popViewController(animated: true)
    }))
    present(ac, animated: true)
  }
  
  @IBAction func runScript() {
    // Create the return parameters to be sent back to Safari's page through the extension
    let item = NSExtensionItem()
    let argument: NSDictionary = ["customJavascript": script?.text ?? ""]
    let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
    let customJavascript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
    item.attachments = [customJavascript]
    extensionContext?.completeRequest(returningItems: [item])
    
    navigationController?.popViewController(animated: true)
  }

}
