//
//  Capital.swift
//  MapKit_Project1
//
//  Created by Alexander on 5/18/19.
//  Copyright © 2019 Dictality. All rights reserved.
//

import UIKit
import MapKit

class Capital: NSObject, MKAnnotation {
  var title: String?
  var coordinate: CLLocationCoordinate2D
  var info: String
  
  init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
    self.title = title
    self.coordinate = coordinate
    self.info = info
  }
}
