//
//  DetailsViewController.swift
//  MapKit_Project1
//
//  Created by Alexander on 5/18/19.
//  Copyright © 2019 Dictality. All rights reserved.
//

import UIKit
import WebKit

class DetailsViewController: UIViewController {

  @IBOutlet weak var webView: WKWebView!
  var city: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.setNavigationBarHidden(false, animated: true)
    title = city
    
    if let url = URL(string: "https://en.wikipedia.org/wiki/\(city!)") {
      webView.load(URLRequest(url: url))
    } else {
      print("ERROR: Unable to parse URL.")
    }
    
  }

}
