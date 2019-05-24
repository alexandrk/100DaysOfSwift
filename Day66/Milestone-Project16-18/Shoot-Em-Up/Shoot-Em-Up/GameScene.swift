//
//  GameScene.swift
//  Shoot-Em-Up
//
//  Created by Alexander Kazakov on 5/25/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
  
  private var entities = [Entity]()
  private var counter = 0
  private var score = 0 {
    didSet {
      scoreLabel.text = "Score: \(score)"
    }
  }
  private var scoreLabel: SKLabelNode!
  
  override func didMove(to view: SKView) {
//    let background = SKSpriteNode(imageNamed: "BG_Decor")
//    background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
//    background.blendMode = .replace
//    background.zPosition = -1
//    addChild(background)
//
//    let ground = SKSpriteNode(imageNamed: "Ground")
//    ground.position = CGPoint(x: self.size.width / 2, y: self.size.width / 2 - 50)
//    ground.zPosition = 1
//    addChild(ground)
//
//    let foreground = SKSpriteNode(imageNamed: "Foreground")
//    foreground.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
//    foreground.zPosition = 0
//    addChild(foreground)
    
    scoreLabel = SKLabelNode(text: "Score: 0")
    scoreLabel.fontName = "Chalkduster"
    scoreLabel.fontSize = 48
    scoreLabel.position = CGPoint(x: 8, y: 8)
    scoreLabel.horizontalAlignmentMode = .left
    addChild(scoreLabel)
    
    Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { (timer) in
      if self.counter < 10 {
        self.createEntity(atRow: .bottom, scale: .large, direction: .right)
      }
      if self.counter < 10 {
        self.createEntity(atRow: .middle, scale: .medium, direction: .left)
      }
      if self.counter < 10 {
        self.createEntity(atRow: .top, scale: .small, direction: .right)
      }
      self.counter += 1
    }
  }
  
  func createEntity(atRow: YOffset, scale: EntitySize, direction: Direction) {
    let entity = Entity(screenSize: self.frame)
    entity.zPosition = 0
    entity.configure(atRow: atRow, scale: scale, direction: direction)
    addChild(entity)
    entity.animate()
    entity.move()
    entities.append(entity)
  }
  
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
    
    for node in children {
      
       if let entity = node as? Entity {
        if entity.characterType.side == .bad {
          if (entity.direction == .right && entity.position.x > frame.width) ||
             (entity.direction == .left && entity.position.x < 0) {
            score -= 1
            node.removeFromParent()
          }
        }
      }
      
      if node.position.x > frame.width + 150 || node.position.x < -150 {
        node.removeFromParent()
      }
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch = touches.first!
    let location = touch.location(in: self)

    let touchesNodes = nodes(at: location)
    
    for node in touchesNodes where node.name != nil {
      
      if node.name!.contains("bad") {
        let sound = SKAction.playSoundFileNamed("bodyFallDirt.mp3", waitForCompletion: true)
        run(sound)
        score += 5
        node.removeFromParent()
      } else if node.name!.contains("good") {
        let sound = SKAction.playSoundFileNamed("missedShot.mp3", waitForCompletion: true)
        run(sound)
        score -= 5
      }
    }
  }
}
