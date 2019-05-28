//
//  Settings.swift
//  Shoot-Em-Up
//
//  Created by Alexander Kazakov on 6/2/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import Foundation
import UIKit

struct Settings {
  static let gameTimer = 20
  static let defaultScore = 0
  
  // Colors
  static let mainTextColor        = UIColor(red: 0, green: 0.45, blue: 0.85, alpha: 1.0)//UIColor(red: 0.31, green: 0.29, blue: 0.33, alpha: 1.0)
  static let mainTextStrokeColor  = UIColor.white
  
  static let gameOverTextColor    = UIColor(red: 1, green: 0.25, blue: 0.21, alpha: 1.0)
  static let gameOverStrokeColor  = UIColor.black
  
  static let playAgainTextColor   = UIColor(red: 0, green: 0.45, blue: 0.85, alpha: 1.0)
  
  // Attributed Text
  static let mainTextStrokeWidth  = -2
  static let mainTextFont         = UIFont(name: "AmericanTypewriter-Bold", size: 48) ?? UIFont.systemFont(ofSize: 48)
  static let gameOverTextFont     = UIFont(name: "AmericanTypewriter-Bold", size: 65) ?? UIFont.systemFont(ofSize: 65)
  
  static let mainTextAttributes: [NSAttributedString.Key: Any] = [
    NSAttributedString.Key.font           : Settings.mainTextFont,
    NSAttributedString.Key.foregroundColor: Settings.mainTextColor,
    NSAttributedString.Key.strokeColor    : Settings.mainTextStrokeColor,
    NSAttributedString.Key.strokeWidth    : Settings.mainTextStrokeWidth
  ]
  
  static let gameOverTextAttributes: [NSAttributedString.Key: Any] = [
    NSAttributedString.Key.font             : Settings.gameOverTextFont,
    NSAttributedString.Key.foregroundColor  : Settings.gameOverTextColor,
    NSAttributedString.Key.strokeColor      : Settings.gameOverStrokeColor,
    NSAttributedString.Key.strokeWidth      : Settings.mainTextStrokeWidth
  ]
  
  static let playAgainTextAttributes: [NSAttributedString.Key: Any] = [
    NSAttributedString.Key.font             : Settings.mainTextFont,
    NSAttributedString.Key.foregroundColor  : Settings.playAgainTextColor,
    NSAttributedString.Key.strokeColor      : Settings.mainTextStrokeColor,
    NSAttributedString.Key.strokeWidth      : Settings.mainTextStrokeWidth
  ]
  
}
