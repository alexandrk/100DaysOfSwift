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
    entity.move(direction: direction)
    entities.append(entity)
  }
  
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
    
    print("Total nodes: \(children.count)")
    print("----------------------------------")
    for node in children {
      if node.position.x > frame.width + 150 || node.position.x < -150 {
        node.removeFromParent()
      }
      else {
        print(node.position.x, separator: ", ")
      }
    }
    print("----------------------------------")
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch = touches.first!
    let location = touch.location(in: self)

    let touchesNodes = nodes(at: location)
    
    for node in touchesNodes where node.name != nil && node.name!.contains("bad") {
      let sound = SKAction.playSoundFileNamed("bodyFallDirt.mp3", waitForCompletion: true)
      run(sound)
      node.removeFromParent()
    }
  }
}
