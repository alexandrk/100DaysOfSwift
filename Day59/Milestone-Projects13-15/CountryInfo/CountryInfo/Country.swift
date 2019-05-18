//
//  Country.swift
//  CountryInfo
//
//  Created by Alexander Kazakov on 5/16/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit

struct Country: Decodable {
  let name: String
  let capital: String
  let region: String
  let subregion: String
  let population: Int
  let flag: String
  let topLevelDomain: [String]
  let timezones: [String]
  let currencies: [[String: String?]]
  let languages: [[String: String?]]
  let borders: [String]
}
