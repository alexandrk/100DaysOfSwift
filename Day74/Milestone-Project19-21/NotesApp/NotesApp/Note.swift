//
//  Note.swift
//  NotesApp
//
//  Created by Alexander Kazakov on 7/2/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import Foundation

class Note: Codable {
  let id: String!
  var content: String!
  
  init(content: String) {
    self.id = UUID().uuidString
    self.content = content
  }
}
