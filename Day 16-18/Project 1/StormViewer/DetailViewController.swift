//
//  DetailViewController.swift
//  StormViewer
//
//  Created by Alexander Kazakov on 3/15/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

  @IBOutlet var imageView: UIImageView!
  var selectedImage: String?
  var navBarTitle: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = (navBarTitle != nil) ? navBarTitle : selectedImage
    navigationItem.largeTitleDisplayMode = .never
    
    if let imagePath = selectedImage {
      imageView.image = UIImage(named: imagePath, in: Bundle.main, compatibleWith: nil)
    }
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.hidesBarsOnTap = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.hidesBarsOnTap = false
  }
}
