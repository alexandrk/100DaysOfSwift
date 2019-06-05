//
//  DataManager.swift
//  Extension
//
//  Created by Alexander on 6/16/19.
//  Copyright © 2019 Dictality. All rights reserved.
//

import Foundation

class DataManager {
  
  static func save(data: [Script], key: String) {
    let encoded = encode(data: data)
    //UserDefaults.standard.removeObject(forKey: key)
    UserDefaults.standard.set(encoded, forKey: key)
    //print("Saving Data for Key: \(key)")
  }
  
  func remove(data: Data, key: String) {
    
  }
  
  private static func encode(data: [Script]) -> Data {
    if let encoded = try? JSONEncoder().encode(data) {
      return encoded
    } else {
      fatalError("Error: encoding default scripts before saving to UserDefaults.")
    }
  }
  
  private static func decode(data: Data) -> [Script] {
    do {
      return try JSONDecoder().decode([Script].self, from: data)
    } catch {
      fatalError("Unable to decode UserDefaults scripts data.")
    }
  }
  
  static func retreive(for key: String) -> [Script] {
    if let savedData = UserDefaults.standard.data(forKey: key) {
      //print("Retreiving Saved Data for Key: \(key)")
      return decode(data: savedData)
    } else {
      return [Script]()
    }
  }
}
