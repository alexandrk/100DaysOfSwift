//
//  DetailViewController.swift
//  FavouriteThings
//
//  Created by Alexander Kazakov on 5/1/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var label: UILabel!
  var thing: Thing!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    title = thing.name.capitalized
    
    let thingImageFile = HelperFuncs.getDocumentsDirectory().appendingPathComponent(thing.filename).path
    imageView.image = UIImage(contentsOfFile: thingImageFile)
    label.text = thing.description ?? ""
  }
    

}
