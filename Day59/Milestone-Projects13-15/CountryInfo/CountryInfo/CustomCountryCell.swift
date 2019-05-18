//
//  CustomCountryCell.swift
//  CountryInfo
//
//  Created by Alexander Kazakov on 5/16/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit
import WebKit

class CustomCountryCell: UITableViewCell {

  @IBOutlet weak var webView: WKWebView!
  
  override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)

      // Configure the view for the selected state
  }

}
