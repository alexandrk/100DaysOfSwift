//
//  HelperFuncs.swift
//  FavouriteThings
//
//  Created by Alexander Kazakov on 5/1/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import Foundation

class HelperFuncs {
  
  /***
   Returns URL for the Documents Directory of the current App
 */
  static func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
  }
  
}
