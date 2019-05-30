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
  private var scoreLabel: SKLabelNode!
  private var gameOverNode: SKLabelNode!
  private var playAgainNode: SKLabelNode!
  private var gameTimerAction: SKAction!
  private var row1LastUpdateInterval: TimeInterval!
  private var row2LastUpdateInterval: TimeInterval!
  private var row3LastUpdateInterval: TimeInterval!
  private var row1EntityInterval: TimeInterval!
  private var row2EntityInterval: TimeInterval!
  private var row3EntityInterval: TimeInterval!
  private var isGameOver = false
  
  private var timeLeft = Settings.gameTimer {
    didSet {
      timerLabel.attributedText = NSAttributedString(string: "Time Left: \(timeLeft)", attributes: Settings.mainTextAttributes)
    }
  }
  private var score = Settings.defaultScore {
    didSet {
      scoreLabel.attributedText = NSAttributedString(string: "Score: \(score)", attributes: Settings.mainTextAttributes)
    }
  }
  
  override func didMove(to view: SKView) {
    let background = SKSpriteNode(imageNamed: "BG_Decor")
    background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
    background.blendMode = .replace
    background.zPosition = -1
    addChild(background)

    let ground = SKSpriteNode(imageNamed: "Ground")
    ground.position = CGPoint(x: self.size.width / 2, y: self.size.width / 2 - 50)
    ground.zPosition = 6
    addChild(ground)

    let foreground = SKSpriteNode(imageNamed: "Foreground")
    foreground.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
    foreground.zPosition = 5
    addChild(foreground)
    
    timerLabel = SKLabelNode(attributedText: NSAttributedString(string: "Time Left: \(timeLeft)", attributes: Settings.mainTextAttributes))
    timerLabel.position = CGPoint(x: frame.width - 350, y: frame.height - 70)
    timerLabel.horizontalAlignmentMode = .left
    timerLabel.zPosition = 20
    addChild(timerLabel)
    
    scoreLabel = SKLabelNode(attributedText: NSAttributedString(string: "Score: 0", attributes: Settings.mainTextAttributes))
    scoreLabel.position = CGPoint(x: 8, y: frame.height - 70)
    scoreLabel.horizontalAlignmentMode = .left
    scoreLabel.zPosition = 20
    addChild(scoreLabel)

    reloadSprite = SKLabelNode(attributedText: NSAttributedString(string: "RELOAD!", attributes: Settings.mainTextAttributes))
    reloadSprite.zPosition = 20
    reloadSprite.position = CGPoint(x: frame.width - 125, y: 100)
    
    gameTimerAction = SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.run { [unowned self] in
      if self.timeLeft > 0 {
        self.timeLeft -= 1
      } else {
        self.gameOver()
        self.removeAction(forKey: "gameTimerAction")
      }
    }]))
    
    row1EntityInterval = Settings.randomTimeInterval
    row2EntityInterval = Settings.randomTimeInterval
    row3EntityInterval = Settings.randomTimeInterval
    
    setupBullets()
    
    run(gameTimerAction, withKey: "gameTimerAction")
    
  }
  
  func sendEntities(currentTime: TimeInterval) {
    
    if currentTime - row1LastUpdateInterval > row1EntityInterval {
      createEntity(atRow: .bottom, scale: .large, direction: .right)
      row1LastUpdateInterval = currentTime
      row1EntityInterval = Settings.randomTimeInterval
    }
    if currentTime - row2LastUpdateInterval > row2EntityInterval {
      createEntity(atRow: .middle, scale: .medium, direction: .left)
      row2LastUpdateInterval = currentTime
      row2EntityInterval = Settings.randomTimeInterval
    }
    if currentTime - row3LastUpdateInterval > row3EntityInterval {
      createEntity(atRow: .top, scale: .small, direction: .right)
      row3LastUpdateInterval = currentTime
      row3EntityInterval = Settings.randomTimeInterval
    }
  
  }
  
  func gameOver() {
    gameOverNode = SKLabelNode(attributedText: NSAttributedString(string: "GAME OVER", attributes: Settings.gameOverTextAttributes))
    gameOverNode.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
    gameOverNode.zPosition = 20
    gameOverNode.xScale = 0.1
    gameOverNode.yScale = 0.1
    addChild(gameOverNode)
    
    gameOverNode.run(SKAction.scale(to: 1, duration: 0.5))
    
    isGameOver = true
    
    playAgainNode = SKLabelNode(attributedText: NSAttributedString(string: "Play Again?", attributes: Settings.playAgainTextAttributes))
    playAgainNode.name = "play-again"
    playAgainNode.position = CGPoint(x: frame.width / 2, y: frame.height / 2 - 70)
    playAgainNode.zPosition = 20
    
    run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run { self.addChild(self.playAgainNode) }]))
    
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
      bullet.zPosition = 20
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
    
    switch atRow {
      case .bottom: entity.zPosition = 6
      case .middle: entity.zPosition = 1
      case .top: entity.zPosition = 2
    }
    
    entity.configure(atRow: atRow, scale: scale, direction: direction)
    addChild(entity)
    entity.animate()
    entity.move()
    entities.append(entity)
  }
  
  // Called before each frame is rendered
  override func update(_ currentTime: TimeInterval) {
  
    guard !isGameOver else { return }
    
    if row1LastUpdateInterval == nil || row2LastUpdateInterval == nil || row3LastUpdateInterval == nil {
      row1LastUpdateInterval = currentTime
      row2LastUpdateInterval = currentTime
      row3LastUpdateInterval = currentTime
    }
    sendEntities(currentTime: currentTime)
    
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
    
    let touch         = touches.first!
    let location      = touch.location(in: self)
    let touchesNodes  = nodes(at: location)
    
    // Check if Play Again was touched
    
    if touchesNodes.contains(where: { $0.name?.contains("play-again") ?? false }) {
      restartGame()
      return
    }
    
    guard !isGameOver else { return }
    
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
  
  func restartGame() {
    
    // Remove all entity nodes (if any are still present on scene)
    for node in children {
      if let node = node as? Entity {
        node.removeFromParent()
      }
    }
    // Set Timer to default value
    timeLeft = Settings.gameTimer
    // Reset Score
    score = Settings.defaultScore
    // Remove 'Game Over' and 'Play Again' nodes
    gameOverNode.removeFromParent()
    playAgainNode.removeFromParent()
    // Reset bullets
    for bullet in emptyBullets.reversed() {
      bullet.texture = SKTexture(imageNamed: "bullet-full")
      bullet.name = "bullet-full"
      fullBullets.append(bullet)
    }
    emptyBullets.removeAll()
    // Set isGameOver trigger to false
    isGameOver = false
    // Restart Game Timer
    run(gameTimerAction, withKey: "gameTimerAction")

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
