//
//  UIView+Extension.swift
//  FavouriteThings
//
//  Created by Alexander Kazakov on 5/1/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
  func setGradientBackground(colorOne: UIColor, colorTwo: UIColor) {
    
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = bounds
    gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
    gradientLayer.locations = [0, 1]
    gradientLayer.startPoint = CGPoint(x: 0, y: 0)
    gradientLayer.endPoint = CGPoint(x: 1, y: 1.0)
    
    layer.insertSublayer(gradientLayer, at: 0)
  }
}
