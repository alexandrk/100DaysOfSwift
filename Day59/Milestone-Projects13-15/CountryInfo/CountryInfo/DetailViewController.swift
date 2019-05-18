//
//  DetailViewController.swift
//  CountryInfo
//
//  Created by Alexander Kazakov on 5/16/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit
import WebKit

enum Sections: Int {
  case general
  case locaiton
  case currancy
  case languages
}

enum GeneralRows: Int {
  case name
  case population
  case capital
  case topLevelDomains
  case flag
}

enum LocationRows: Int {
  case region
  case subregion
  case timezones
}

enum CurrancyRows: Int {
  case code
  case name
  case symbol
}

enum LanguagesRows: Int {
  case iso639_1
  case iso639_2
  case name
  case nativeName
}

class DetailViewController: UITableViewController {

  var country: Country!
  @IBOutlet weak var webView: WKWebView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = country.name
    
//    if let url = URL(string: country.flag) {
//      webView.load(URLRequest(url: url))
//    } else {
//      print("Unable to load image from: \(country.flag)")
//    }
    
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = super.tableView(tableView, cellForRowAt: indexPath)
    
    switch indexPath.section {
    case Sections.general.rawValue:
      switch indexPath.row {
      case GeneralRows.name.rawValue: cell.textLabel?.text = country.name
      case GeneralRows.population.rawValue:
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        cell.textLabel?.text = formatter.string(from: NSNumber(value: country.population))
      case GeneralRows.capital.rawValue: cell.textLabel?.text = String(country.capital)
      case GeneralRows.topLevelDomains.rawValue: cell.textLabel?.text = country.topLevelDomain.joined(separator: ", ")
      case GeneralRows.flag.rawValue:
        let webKitViewInPixels = Int(webView.frame.width * UIScreen.main.scale)
        webView.layer.borderColor = UIColor.gray.cgColor
        webView.layer.borderWidth = 2
        webView.loadHTMLString(CountryFlagHtml.getFlagImage(width: webKitViewInPixels, flagURL: country.flag), baseURL: nil) 
      default: break
      }
    case Sections.locaiton.rawValue:
      switch indexPath.row {
      case LocationRows.region.rawValue: cell.textLabel?.text = country.region
      case LocationRows.subregion.rawValue: cell.textLabel?.text = country.subregion
      case LocationRows.timezones.rawValue: cell.textLabel?.text = country.timezones.joined(separator: ", ")
      default: break
      }
    case Sections.currancy.rawValue:
      let currency = country.currencies[0]
      switch indexPath.row {
      case CurrancyRows.code.rawValue: cell.textLabel?.text = currency["code", default: "[No Data]"] ?? "[No Data]"
      case CurrancyRows.name.rawValue: cell.textLabel?.text = currency["name", default: "[No Data]"] ?? "[No Data]"
      case CurrancyRows.symbol.rawValue: cell.textLabel?.text = currency["symbol", default: "[No Data]"] ?? "[No Data]"
      default: break
      }
    case Sections.languages.rawValue:
      let languages = country.languages[0]
      switch indexPath.row {
      case LanguagesRows.iso639_1.rawValue: cell.textLabel?.text = languages["iso639_1", default: "[No Data]"] ?? "[No Data]"
      case LanguagesRows.iso639_2.rawValue: cell.textLabel?.text = languages["iso639_2", default: "[No Data]"] ?? "[No Data]"
      case LanguagesRows.name.rawValue: cell.textLabel?.text = languages["name", default: "[No Data]"] ?? "[No Data]"
      case LanguagesRows.nativeName.rawValue: cell.textLabel?.text = languages["nativeName", default: "[No Data]"] ?? "[No Data]"
      default: break
      }
    default: break
    }
   
    return cell
  }
  
}
