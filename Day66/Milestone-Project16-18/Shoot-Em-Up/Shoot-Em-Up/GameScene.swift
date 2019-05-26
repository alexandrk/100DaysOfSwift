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
  private var bullets = [SKSpriteNode]()
  private var reloadSprite: SKLabelNode!
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

    reloadSprite = SKLabelNode(text: "RELOAD!")
    reloadSprite.position = CGPoint(x: frame.width - 125, y: 10)
    reloadSprite.fontSize = 48
    
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
    
    setupBullets()
    
  }
  
  func setupBullets() {
    
    var xPosition: CGFloat = size.width - 50
    let yPosition:CGFloat = 8
    var bulletPosition: CGPoint!
    
    for _ in 1...6 {
      let bullet = SKSpriteNode(imageNamed: "bullet-full")
      bulletPosition = CGPoint(x: xPosition, y: yPosition)
      bullet.position = bulletPosition
      bullet.anchorPoint = CGPoint(x: 0, y: 0)
      bullet.zPosition = 3
      bullet.xScale = 0.35
      bullet.yScale = 0.35
      bullet.name = "bullet-full"
      
      addChild(bullet)
      bullets.append(bullet)
      
      xPosition -= 35
    }
    bullets.reverse()
    
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
    
    if touchesNodes.contains(where: { $0.name?.contains("bullet") ?? false }) {
      reloadBullets(touchesNodes: touchesNodes)
    } else {
      subtractBullet()
    }
    
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
  
  
  func subtractBullet() {
    
    guard reloadSprite.parent == nil else { return }
    
    if let lastUnusedBullet = bullets.last(where: {$0.name == "bullet-full"}) {
      lastUnusedBullet.texture = SKTexture(imageNamed: "bullet-used")
      lastUnusedBullet.name = "bullet-used"
    } else {
//      let reloadSprite = SKSpriteNode(imageNamed: "reload")
//      reloadSprite.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
//      //reloadSprite.anchorPoint = CGPoint(x: reloadSprite.frame.width / 2, y: 0)
//      reloadSprite.zPosition = 3
//      reloadSprite.xScale = 0.35
//      reloadSprite.yScale = 0.35
      
      let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
      let fadeInAction = SKAction.fadeIn(withDuration: 0.5)
      let moveAction = SKAction.move(by: CGVector(dx: 0, dy: 50), duration: 0.5)
      let addReloadSpriteAction = SKAction.run { self.addChild(self.reloadSprite) }
      let waitAction = SKAction.wait(forDuration: 1)
      let bulletFlashSequence = SKAction.repeatForever(SKAction.sequence([fadeOutAction, fadeInAction, waitAction]))
      
      var bulletActionCompletedCounter = 0
      for bullet in bullets {
        bullet.run(moveAction) {
          bulletActionCompletedCounter += 1
          
          // All bullets moved higher
          if bulletActionCompletedCounter == self.bullets.count {
            if self.reloadSprite.parent == nil {
              self.run(addReloadSpriteAction)
            } else {
              print("RELOAD SPRITE PRESENT: \(self.reloadSprite.parent)")
              for bullet in self.bullets {
                bullet.run(bulletFlashSequence)
              }
              self.reloadSprite.run(bulletFlashSequence)
            }
          }
        }
      }
      
      addChild(reloadSprite)
    }
  }
  
  func reloadBullets(touchesNodes: [SKNode]) {
    if touchesNodes.contains(where: { $0.name?.contains("bullet") ?? false }) {
      let bullet = bullets.first(where: {$0.name == "bullet-used"})
      bullet?.texture = SKTexture(imageNamed: "bullet-full")
      bullet?.name = "bullet-full"
      
      // Remove Reload Sprite
      reloadSprite.removeAllActions()
      reloadSprite.removeFromParent()
      
      // Move bullets back to place
      for bullet in bullets {
        if bullet.hasActions() {
          bullet.run(SKAction.move(by: CGVector(dx: 0, dy: -50), duration: 0.5)) {
            // Remove blinking action
            bullet.removeAllActions()
          }
        }
      }
    }
  }
  
}
