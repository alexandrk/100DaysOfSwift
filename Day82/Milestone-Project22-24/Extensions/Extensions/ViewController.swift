//
//  ViewController.swift
//  Extensions
//
//  Created by Alexander on 7/19/19.
//  Copyright © 2019 Dictality. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var bigButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bigButton.layer.cornerRadius = 5
    bigButton.layer.borderWidth = 2
    bigButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    bigButton.layer.borderColor = UIColor.black.cgColor
  }

  @IBAction func touchAction(_ sender: Any) {
    bigButton.bounceOut(duration: 2)
    
    5.times {
      print("La-la-la")
    }
    
    var array = [1, 2, 1, 3, 2, 4, 3, 5, 4, 6, 5, 6]
    print("Array before .remove(item:) extenison method: \(array)")
    print("Results of using .remove(item:) extension method: \(array.remove(item: 4) ?? 0)")
    print("Array after .remove(item:) extenison method: \(array)")
  }
  
}

