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
  private var fullBullets = [SKSpriteNode]()
  private var emptyBullets = [SKSpriteNode]()
  private var reloadSprite: SKLabelNode!
  private var timerLabel: SKLabelNode!
  private var gameOverNode: SKLabelNode!
  private var isGameOver = false
  private let textFontAttributes: [NSAttributedString.Key: Any] = [
    NSAttributedString.Key.font: UIFont(name: "AmericanTypewriter-Bold", size: 48) ?? UIFont.systemFont(ofSize: 48),
    NSAttributedString.Key.foregroundColor: UIColor(red: 0.31, green: 0.29, blue: 0.33, alpha: 1.0),
    NSAttributedString.Key.strokeColor: UIColor.white,
    NSAttributedString.Key.strokeWidth: -2
  ]
  private var timeLeft = 20 {
    didSet {
      timerLabel.attributedText = NSAttributedString(string: "Time Left: \(timeLeft)", attributes: textFontAttributes)
    }
  }
  private var counter = 0
  private var score = 0 {
    didSet {
      scoreLabel.attributedText = NSAttributedString(string: "Score: \(score)", attributes: textFontAttributes)
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
    
    timerLabel = SKLabelNode(attributedText: NSAttributedString(string: "Time Left: \(timeLeft)", attributes: textFontAttributes))
    timerLabel.position = CGPoint(x: frame.width - 350, y: frame.height - 70)
    timerLabel.horizontalAlignmentMode = .left
    addChild(timerLabel)
    
    scoreLabel = SKLabelNode(attributedText: NSAttributedString(string: "Score: 0", attributes: textFontAttributes))
    scoreLabel.position = CGPoint(x: 8, y: 8)
    scoreLabel.horizontalAlignmentMode = .left
    addChild(scoreLabel)

    reloadSprite = SKLabelNode(attributedText: NSAttributedString(string: "RELOAD!", attributes: textFontAttributes))
    reloadSprite.zPosition = 5
    reloadSprite.position = CGPoint(x: frame.width - 125, y: 100)
    
    let gameTimerAction = SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.run { [weak self] in
      guard let self = self else { return }
      if self.timeLeft > 0 {
        self.timeLeft -= 1
      } else {
        self.gameOver()
        self.removeAction(forKey: "gameTimerAction")
      }
    }]))
    
    Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { [weak self] (timer) in
      guard let self = self else { return }
      if self.timeLeft > 0 {
        self.createEntity(atRow: .bottom, scale: .large, direction: .right)
        self.createEntity(atRow: .middle, scale: .medium, direction: .left)
        self.createEntity(atRow: .top, scale: .small, direction: .right)
      } else {
        timer.invalidate()
      }
    }
    run(gameTimerAction, withKey: "gameTimerAction")
    
    setupBullets()
    
  }
  
  func gameOver() {
    
    var textAttributes = textFontAttributes
    textAttributes[NSAttributedString.Key.font] = UIFont(name: "AmericanTypewriter-Bold", size: 65) ?? UIFont.systemFont(ofSize: 65)
    textAttributes[NSAttributedString.Key.foregroundColor] = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)
    textAttributes[NSAttributedString.Key.strokeColor] = UIColor.black
    
    gameOverNode = SKLabelNode(attributedText: NSAttributedString(string: "GAME OVER", attributes: textAttributes))
    gameOverNode.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
    gameOverNode.xScale = 0.1
    gameOverNode.yScale = 0.1
    addChild(gameOverNode)
    
    gameOverNode.run(SKAction.scale(to: 1, duration: 0.5))
    
    isGameOver = true
  }
  
  func setupBullets() {
    
    var xPosition: CGFloat = size.width - 50
    let yPosition:CGFloat = 8
    var bulletPosition: CGPoint!
    
    for _ in 1...6 {
      let bullet = SKSpriteNode(imageNamed: "bullet-full")
      bulletPosition = CGPoint(x: xPosition, y: yPosition)
      bullet.name = "bullet-full"
      bullet.position = bulletPosition
      bullet.anchorPoint = CGPoint(x: 0, y: 0)
      bullet.zPosition = 3
      bullet.xScale = 0.35
      bullet.yScale = 0.35
      
      addChild(bullet)
      fullBullets.append(bullet)
      
      xPosition -= 36
    }
    fullBullets.reverse()
    
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
  
  // Called before each frame is rendered
  override func update(_ currentTime: TimeInterval) {
    for node in children {
      // Subtraсts points if the "Bad / Enemy" entity reaches the other side alive
      if let entity = node as? Entity {
        if entity.characterType.side == .bad {
          if (entity.direction == .right && entity.position.x > frame.width) ||
             (entity.direction == .left && entity.position.x < 0) {
            score -= 1
            node.removeFromParent()
          }
        }
      }
      
      // Removes all nodes that go off screen
      if node.position.x > frame.width + 150 || node.position.x < -150 {
        // Does attempt to remove "Bad / Enemy" entities that reached the other side alive,
        // but doesn't fail if the node is already removed from parent. So, is fine.
        node.removeFromParent()
      }
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    guard !isGameOver else { return }
    
    let touch         = touches.first!
    let location      = touch.location(in: self)
    let touchesNodes  = nodes(at: location)
    
    // Tries to reload bullets, if one of the  bullet is touched
    if touchesNodes.contains(where: { $0.name?.contains("bullet") ?? false }) {
      reloadBullets()
    }
    // Else uses one of the bullets
    else {
      if !fullBullets.isEmpty {
        subtractBullet()
        run(SKAction.playSoundFileNamed("shotFired.mp3", waitForCompletion: false))
      } else {
        run(SKAction.playSoundFileNamed("dryShot.mp3", waitForCompletion: false))
      }
    }
    
    // Return if no more bullets left
    guard !fullBullets.isEmpty else { return }
    
    // See if any of the Entities were hit (either bad or good ones)
    for node in touchesNodes where node.name != nil {
      if node.name!.contains("bad") {
        let sound = SKAction.playSoundFileNamed("bodyFallDirt.mp3", waitForCompletion: false)
        run(sound)
        score += 5
        node.removeFromParent()
      } else if node.name!.contains("good") {
        let sound = SKAction.playSoundFileNamed("missedShot.mp3", waitForCompletion: false)
        run(sound)
        score -= 5
      }
    }
  }
  
  
  func subtractBullet() {
    
    guard reloadSprite.parent == nil else { return }
    
    if !fullBullets.isEmpty {
      let usedBullet = fullBullets.popLast()!
      usedBullet.texture = SKTexture(imageNamed: "bullet-used")
      usedBullet.name = "bullet-used"
      emptyBullets.append(usedBullet)
      
      // If that was the last bullet show animation for reloading
      if fullBullets.isEmpty {
        let bulletFlashSequence = SKAction.repeatForever(SKAction.sequence([
          SKAction.fadeOut(withDuration: 0.5),
          SKAction.fadeIn(withDuration: 0.5),
          SKAction.wait(forDuration: 1)
        ]))
        
        addChild(reloadSprite)
        
        for bullet in self.emptyBullets {
          bullet.run(bulletFlashSequence)
        }
        self.reloadSprite.run(bulletFlashSequence)
      }
    }
    
  }
  
  func reloadBullets() {
    guard !emptyBullets.isEmpty else { return }
    
    let bullet = emptyBullets.popLast()!
    bullet.texture = SKTexture(imageNamed: "bullet-full")
    bullet.name = "bullet-full"
    fullBullets.append(bullet)
      
    // Remove Reload Sprite
    reloadSprite.removeAllActions()
    reloadSprite.removeFromParent()
      
    // Removes a blinking action and Resets bullets alpha value to 1
    for bullet in fullBullets + emptyBullets {
      bullet.removeAllActions()
      bullet.alpha = 1
    }
  }
  
}
