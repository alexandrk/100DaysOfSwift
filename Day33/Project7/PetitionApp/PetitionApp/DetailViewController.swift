//
//  DetailViewController.swift
//  PetitionApp
//
//  Created by Alexander Kazakov on 4/7/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
  var webView: WKWebView!
  var detailItem: Petition?
  
  override func loadView() {
    webView = WKWebView()
    view = webView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = detailItem?.title
    
    guard let detailItem = detailItem else { return }
    let html = """
    <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>body {font-size: 150%;}</style>
      </head>
      <body>
        \(detailItem.body)
      </body>
    </html>
    """
    webView.loadHTMLString(html, baseURL: nil)
    
  }

}
