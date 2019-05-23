//
//  File.swift
//  Shoot-Em-Up
//
//  Created by Alexander Kazakov on 5/27/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import Foundation

enum AllowedCharacter: String {
  case fallenAngel1 = "FallenAngel_1"
  case fallenAngel2 = "FallenAngel_2"
  case fallenAngel3 = "FallenAngel_3"
  case fantasyTroll1 = "FantasyTroll_1"
  case fantasyTroll2 = "FantasyTroll_2"
  case fantasyTroll3 = "FantasyTroll_3"
  
  case fantasyFairy1 = "FantasyFairy_1"
  case fantasyFairy2 = "FantasyFairy_2"
  case fantasyFairy3 = "FantasyFairy_3"
  case fantasyElf1 = "FantasyElf_1"
  case fantasyElf2 = "FantasyElf_2"
  case fantasyElf3 = "FantasyElf_3"
}

enum CharacterSide: String {
  case good = "good"
  case bad = "bad"
}

struct CharacterType {
  
  let type : AllowedCharacter
  let side: CharacterSide
  
  static let characters: [AllowedCharacter] =
    [.fallenAngel1, .fallenAngel2, .fallenAngel3, .fantasyTroll1, .fantasyTroll2, .fantasyTroll3,
     .fantasyFairy1, .fantasyFairy2, .fantasyFairy3, .fantasyElf1, .fantasyElf2, .fantasyElf3]
  
  init(characterType: AllowedCharacter) {
    type = characterType
    
    switch type {
      case .fallenAngel1, .fallenAngel2, .fallenAngel3, .fantasyTroll1, .fantasyTroll2, .fantasyTroll3: side = .bad
      case .fantasyElf1, .fantasyElf2, .fantasyElf3, .fantasyFairy1, .fantasyFairy2, .fantasyFairy3: side = .good
    }
    
    
    
  }
}
