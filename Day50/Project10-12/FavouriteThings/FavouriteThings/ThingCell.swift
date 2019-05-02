//
//  ThingCell.swift
//  FavouriteThings
//
//  Created by Alexander Kazakov on 4/27/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit

class ThingCell: UICollectionViewCell {
    
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  
  var thing: Thing! {
    didSet {
      let thingImageFile = HelperFuncs.getDocumentsDirectory().appendingPathComponent(thing.filename).path
      imageView.image = UIImage(contentsOfFile: thingImageFile)
      imageView.layer.cornerRadius = 5
      imageView.layer.masksToBounds = true
      nameLabel.text = thing.name
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    myInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    myInit()
  }
  
  private func myInit() {
    layer.cornerRadius = 5
    layer.masksToBounds = true
    let colorOne = UIColor(red:0.13, green:0.76, blue:0.82, alpha:1.0)
    let colorTwo = UIColor(red:0.90, green:0.98, blue:1.00, alpha:1.0)
    setGradientBackground(colorOne: colorOne, colorTwo: colorTwo)
  }
}
