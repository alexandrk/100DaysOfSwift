//
//  DetailViewController.swift
//  Milestone: Projects 1-3
//
//  Created by Alexander Kazakov on 3/24/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

  var imageName: String!
  private var countryName = ""
  @IBOutlet weak var imageView: UIImageView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    countryName = imageName.split(separator: ".")[0].uppercased()
    title = countryName
    imageView.image = UIImage(named: imageName)
    imageView.layer.borderColor = UIColor.gray.cgColor
    imageView.layer.borderWidth = 1
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareImage))
  }
  
  @objc func shareImage() {
    guard let compressedImage = imageView.image?.jpegData(compressionQuality: 0.8) else {
      print("No image found")
      return
    }
    
    let activity = UIActivityViewController(activityItems: [countryName, compressedImage], applicationActivities: nil)
    activity.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
    present(activity, animated: true, completion: nil)
  }
}
