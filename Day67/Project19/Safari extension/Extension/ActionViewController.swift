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

}
