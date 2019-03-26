//
//  ViewController.swift
//  SimpleWebBrowser
//
//  Created by Alexander Kazakov on 3/25/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
  
  var webView: WKWebView!
  var progressView: UIProgressView!
  private var websites = ["apple.com", "hackingwithswift.com"]
  private let colorBlue = UIColor(red: 0.019, green: 0.478, blue: 1.0, alpha: 1.0)
  
  override func loadView() {
    webView = WKWebView()
    webView.navigationDelegate = self
    view = webView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
    
    // Setting up ProgressView
    progressView = UIProgressView(progressViewStyle: .default)
    progressView.sizeToFit()
    let progressButton = UIBarButtonItem(customView: progressView)
    
    // Adding Toolbar to the view
    let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
    let goBack = UIBarButtonItem(barButtonSystemItem: .rewind, target: webView, action: #selector(webView.goBack))
    let goForward = UIBarButtonItem(barButtonSystemItem: .fastForward, target: webView, action: #selector(webView.goForward))
    
    goBack.tintColor = .gray
    goForward.tintColor = .gray
    
    toolbarItems = [goBack, goForward, spacer, progressButton, spacer, refresh]
    navigationController?.isToolbarHidden = false
    
    webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
    webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)
    
    // Initial page to be loaded in webView
    let url = URL(string: "https://www." + websites.first!)!
    webView.load(URLRequest(url: url))
    webView.allowsBackForwardNavigationGestures = true
  }

  @objc func openTapped() {
    let ac = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)
    
    for website in websites {
      ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
    }
    
    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
    present(ac, animated: true)
  }
  
  func openPage(action: UIAlertAction) {
    let url = URL(string: "https://" + action.title!)!
    webView.load((URLRequest(url: url)))
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    title = webView.title
  }
  
  // KVO for page load progress
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    switch keyPath {
      case "estimatedProgress":
        progressView.progress = Float(webView.estimatedProgress)
      case "canGoBack":
        toolbarItems?[0].tintColor = (webView.canGoBack) ? self.colorBlue : UIColor.gray
      case "canGoForward":
        toolbarItems?[1].tintColor = (webView.canGoForward) ? self.colorBlue : UIColor.gray
      default: break
    }
    
  }
  
  // Filter the allowed websites to a list
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    let url = navigationAction.request.url
    
    if let host = url?.host {
      for website in websites {
        if host.contains(website) {
          decisionHandler(.allow)
          return
        }
      }
    }
    
    let ac = UIAlertController(title: "WARNING:", message: """
      The website is trying to open a resource outside of monitored area.
      Do you want to proceed with: \(url?.host ?? "UNKNOWN")
      """, preferredStyle: .alert)
    
    ac.addAction(UIAlertAction(title: "PROCEED", style: .default, handler: { (alert) in
        decisionHandler(.allow)
      return
      }))
    ac.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: { alert in
        decisionHandler(.cancel)
        return
      }))
    present(ac, animated: true, completion: nil)
    
    return
  }
}
