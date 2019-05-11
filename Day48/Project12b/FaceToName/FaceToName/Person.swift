//
//  Person.swift
//  FaceToName
//
//  Created by Alexander on 4/19/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit

class Person: NSObject, Codable {
  var name: String
  var image: String
  
  init(name: String, image: String) {
    self.name = name
    self.image = image
  }
}
