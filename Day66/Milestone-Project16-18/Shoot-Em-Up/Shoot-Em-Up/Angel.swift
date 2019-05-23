//
//  Angel.swift
//  Shoot-Em-Up
//
//  Created by Alexander Kazakov on 5/25/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit
import SpriteKit

enum AngelSize: CGFloat {
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

class Angel: SKNode {

  var angel: SKSpriteNode!
  var angelType: Int!
  var walkingFrames: [SKTexture] = []
  var screenSize: CGRect!
  
  init(screenSize: CGRect) {
    super.init()
    self.screenSize = screenSize
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(atRow yOffset: YOffset, scale: AngelSize, direction: Direction) {
    angelType = configureAnimation()
    
    let firstFrameTexture = walkingFrames[0]
    angel = SKSpriteNode(texture: firstFrameTexture)
    angel.anchorPoint = CGPoint(x: 0, y: 0)
    angel.setScale(scale.rawValue)
    angel.xScale = abs(angel.xScale) * direction.rawValue
    
    angel.name = configureName(enemyType: angelType, enemySize: scale)
    
    var xPosition: CGFloat!
    xPosition = (direction == .right) ? -100 : screenSize.width + 100
    self.position = CGPoint(x: xPosition, y: screenSize.height * yOffset.rawValue)
    
    addChild(angel)
  }
  
  func configureAnimation() -> Int {
    let existingTypes = [1, 2, 3]
    let selectedType = existingTypes.randomElement()!
    
    let angelAtlas = SKTextureAtlas(named: "FallenAngel_\(selectedType)_Walking")
    let numImages = angelAtlas.textureNames.count
    
    for i in 1...numImages {
      let textureName = "0_Fallen_Angels_Walking_0\(String(format: "%02d", i)).png"
      walkingFrames.append(angelAtlas.textureNamed(textureName))
    }
    
    return selectedType
  }
  
  func configureName(enemyType: Int, enemySize: AngelSize) -> String {
    var name = ""
    switch enemySize {
    case .large: name = "enemy:large_\(enemyType)"
    case .medium: name = "enemy:medium_\(enemyType)"
    case .small: name = "enemy:small_\(enemyType)"
    }
    return name
  }
  
  func animate() {
    angel.run(SKAction.repeatForever(
      SKAction.animate(with: walkingFrames,
                       timePerFrame: 0.1,
                       resize: false,
                       restore: true)),
              withKey:"angelWalking")
  }
  
  func move(direction: Direction) {
    if direction == .right {
      self.run(SKAction.moveBy(x: screenSize.width + 300, y: 0, duration: 10))
    } else {
      self.run(SKAction.moveBy(x: -(screenSize.width + 300), y: 0, duration: 10))
    }
  }
  
}
