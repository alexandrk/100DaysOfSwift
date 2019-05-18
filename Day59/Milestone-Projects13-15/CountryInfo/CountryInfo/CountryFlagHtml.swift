//
//  CountryFlagHtml.swift
//  CountryInfo
//
//  Created by Alexander Kazakov on 5/16/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import Foundation

struct CountryFlagHtml {
  static func getFlagImage(width: Int, flagURL: String) -> String {
    
    return """
    <html>
    <head>
    <style>
    .center-content {
      height: 100%;
      text-align: center;
    }
    .center-content div {
      display: block;
      margin-left: auto;
      margin-right: auto;
    }
    .bg-svg {
      width: 100%;
      background-image: url(\(flagURL));
      background-size: cover;
      height: 0;
      padding: 0 0 calc(100% * 2 / 3);
    }
    
    </style>
    </head>
    <body>
    <div class="center-content">
      <div style="width:\(width)px">
        <div class="bg-svg">&nbsp;</div>
      </div>
    </div>
    <body>
    </html>
    """
  }
}
