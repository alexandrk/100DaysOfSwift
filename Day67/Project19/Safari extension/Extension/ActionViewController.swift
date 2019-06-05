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

  @IBOutlet weak var script: UITextView!
  var pageTitle = ""
  var pageURL = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
  
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Actions", style: .plain, target: self, action: #selector(showPredefinedScripts))
    
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    
    // Parse the parameters that were passed from the webpage through the extension to the here
    if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
      if let itemProvider = inputItem.attachments?.first {
        itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] (dict, error) in
          
          guard let itemDictionary = dict as? NSDictionary else { return }
          guard let javascriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
          
          self?.pageTitle = javascriptValues["title"] as? String ?? ""
          self?.pageURL = javascriptValues["URL"] as? String ?? ""
          
          DispatchQueue.main.async {
            self?.title = self?.pageTitle
          }
        }
      }
    }
      
  }

  @objc func showPredefinedScripts() {
    
    let scripts = UserDefaults.standard.dictionary(forKey: "default")
    
    let ac = UIAlertController(title: "Default Scripts", message: nil, preferredStyle: .actionSheet)
    
    if let scripts = scripts as? [String: String] {
      for scriptName in scripts.keys {
        guard let defaultScript = scripts[scriptName] else { continue }
        
        ac.addAction(UIAlertAction(title: scriptName, style: .default) { [weak self] (_) in self?.updateTextView(with: defaultScript) })
      }
    } else {
      populateDefaultScripts()
      showPredefinedScripts()
    }
    
    present(ac, animated: true)
  }
  
  func updateTextView(with script: String) {
    self.script.text = script
  }
  
  @objc func adjustForKeyboard(notifcation: Notification) {
    guard let keyboardValue = notifcation.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
    
    let keyboardScreenEndFrame = keyboardValue.cgRectValue
    
    // Here for edge cases, when the keyboard doesn't properly adjust when the phone is rotated horizontally
    let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
    
    if notifcation.name == UIResponder.keyboardWillHideNotification {
      script.contentInset = .zero
    } else {
      script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
    }
    
    // Adjusts the scroll indicator bottom edge properly for when the keyboard is showed (coving the UITextView)
    script.scrollIndicatorInsets = script.contentInset
    
    let selectedRange = script.selectedRange
    script.scrollRangeToVisible(selectedRange)
  }
  
  /// Event Handler for the navigation bar button item
  @IBAction func done() {
    // Create the return parameters to be sent back to Safari's page through the extension
    let item = NSExtensionItem()
    let argument: NSDictionary = ["customJavascript": script.text ?? ""]
    let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
    let customJavascript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
    item.attachments = [customJavascript]
    extensionContext?.completeRequest(returningItems: [item])
  }
  
  // Populates UserDefaults with default scripts available for all pages.
  func populateDefaultScripts() {
    let defaultScripts = ["Simple Alert": "alert('Hello World');", "Show Web Page Title": "alert(document.title);"]
    UserDefaults.standard.set(defaultScripts, forKey: "default")
  }

}
