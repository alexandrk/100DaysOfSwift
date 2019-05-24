//
//  Character.swift
//  Shoot-Em-Up
//
//  Created by Alexander Kazakov on 5/25/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit
import SpriteKit

enum EntitySize: CGFloat {
  case small = 0.18
  case medium = 0.25
  case large = 0.35
}

enum Direction: CGFloat {
  case left = -1
  case right = 1
}

enum YOffset: CGFloat {
  case top = 0.8
  case middle = 0.35
  case bottom = 0.05
}

class Entity: SKNode {

  var sprite: SKSpriteNode!
  var characterType: CharacterType!
  var walkingFrames: [SKTexture] = []
  var direction: Direction!
  var screenSize: CGRect!
  
  init(screenSize: CGRect) {
    super.init()
    self.screenSize = screenSize
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(atRow yOffset: YOffset, scale: EntitySize, direction: Direction) {
    characterType = CharacterType(characterType: CharacterType.characters.randomElement()!)
    self.direction = direction
    configureAnimation()
    
    let firstFrameTexture = walkingFrames[0]
    sprite = SKSpriteNode(texture: firstFrameTexture)
    sprite.anchorPoint = CGPoint(x: 0, y: 0)
    sprite.setScale(scale.rawValue)
    sprite.xScale = abs(sprite.xScale) * direction.rawValue
    
    sprite.name = configureName(enemySize: scale)
    
    var xPosition: CGFloat!
    xPosition = (direction == .right) ? -100 : screenSize.width + 100
    self.position = CGPoint(x: xPosition, y: screenSize.height * yOffset.rawValue)
    
    addChild(sprite)
  }
  
  func configureAnimation() {
    let characterAtlas = SKTextureAtlas(named: "\(characterType.type.rawValue)_Walking")
    let numImages = characterAtlas.textureNames.count
    
    for i in 1...numImages {
      let textureName = "\(characterType.type.rawValue.split(separator: "_")[0])\(i).png"
      walkingFrames.append(characterAtlas.textureNamed(textureName))
    }
  }
  
  func configureName(enemySize: EntitySize) -> String {
    var name = ""
    switch enemySize {
    case .large: name  = "\(characterType.side.rawValue):large:\(characterType.type.rawValue)"
    case .medium: name = "\(characterType.side.rawValue):medium:\(characterType.type.rawValue)"
    case .small: name  = "\(characterType.side.rawValue):small:\(characterType.type.rawValue)"
    }
    return name
  }
  
  func animate() {
    sprite.run(SKAction.repeatForever(
      SKAction.animate(with: walkingFrames,
                       timePerFrame: 0.1,
                       resize: false,
                       restore: true)),
              withKey:"characterWalking")
  }
  
  func move() {
    if direction == .right {
      self.run(SKAction.moveBy(x: screenSize.width + 300, y: 0, duration: 10))
    } else {
      self.run(SKAction.moveBy(x: -(screenSize.width + 300), y: 0, duration: 10))
    }
  }
  
}
