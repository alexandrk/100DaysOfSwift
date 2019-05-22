//
//  GameScene.swift
//  SpaceAdvanture
//
//  Created by Alexander Kazakov on 5/18/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  var starfield: SKEmitterNode!
  var player: SKSpriteNode!
  
  var scoreLabel: SKLabelNode!
  var playAgain: SKLabelNode!
  
  var possibleEmenies = ["ball", "hammer", "tv"]
  var isGameOver = false
  var allowMove = false
  
  var gameTimer: Timer?
  private var timerInterval: Double = 1
  private var enemiesCreated = 0
  
  var score = 0 {
    didSet {
      scoreLabel.text = "Score: \(score)"
    }
  }
  
  override func didMove(to view: SKView) {
    backgroundColor = .black
    
    starfield = SKEmitterNode(fileNamed: "starfield")!
    starfield.position = CGPoint(x: 1024, y: 384)
    starfield.advanceSimulationTime(10)
    addChild(starfield)
    starfield.zPosition = -1
    
    createPlayer()
    
    scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    scoreLabel.position = CGPoint(x: 16, y: 16)
    scoreLabel.horizontalAlignmentMode = .left
    addChild(scoreLabel)
    
    score = 0
    
    physicsWorld.gravity = .zero
    physicsWorld.contactDelegate = self
    
    gameTimer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
  }
  
  func createPlayer() {
    player = SKSpriteNode(imageNamed: "player")
    player.name = "player"
    player.position = CGPoint(x: 100, y: 384)
    player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
    player.physicsBody?.allowsRotation = false
    player.physicsBody?.contactTestBitMask = 1
    addChild(player)
  }
  
  @objc func createEnemy() {
    
    guard !isGameOver else { return }
    guard let enemy = possibleEmenies.randomElement() else { return }
    
    // Tracks number of enemies created
    enemiesCreated += 1
    
    let sprite = SKSpriteNode(imageNamed: enemy)
    sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
    sprite.name = "enemy"
    addChild(sprite)
    
    sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
    sprite.physicsBody?.categoryBitMask = 1
    sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
    sprite.physicsBody?.angularVelocity = 5
    sprite.physicsBody?.linearDamping = 0
    sprite.physicsBody?.angularDamping = 0
    
    if enemiesCreated % 3 == 0 && timerInterval > 0.1 {
      adjustTimer()
    }
  }
  
  private func adjustTimer() {
    gameTimer?.invalidate()
    
    // Note, timer interval cannot be 0
    timerInterval = (timerInterval - 0.1) < 0.1 ? 0.1 : timerInterval - 0.1
    print(timerInterval)
    gameTimer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
  }
  
  override func update(_ currentTime: TimeInterval) {
    for node in children {
      if node.position.x < -300 {
        node.removeFromParent()
      }
    }
    
    if !isGameOver {
      score += 1
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if allowMove {
      guard let touch = touches.first else { return }
      var location = touch.location(in: self)
      if location.y < 100 {
        location.y = 100
      } else if location.y > 668 {
        location.y = 668
      }
      
      player.position = location
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let location = touch.location(in: self)
    let nodesAtLocation = nodes(at: location)

    if nodesAtLocation.contains(where: { $0.name == "player" }) {
      allowMove = true
    }
    
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let location = touch.location(in: self)
    let nodesAtLocation = nodes(at: location)
    
    // Prevents user from randomly tap anywhere on the screen to relocate the spaceship
    allowMove = false
    
    if nodesAtLocation.contains(where: { $0.name == "playAgain" }) {
      restartGame()
    }
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    let explosion = SKEmitterNode(fileNamed: "explosion")!
    explosion.position = player.position
    
    let addEmitterAction = SKAction.run({self.addChild(explosion)})
    let emitterDuration = CGFloat(explosion.numParticlesToEmit) * explosion.particleLifetime
    let wait = SKAction.wait(forDuration: TimeInterval(emitterDuration / 60))
    let remove = SKAction.run({explosion.removeFromParent()})
    let sequence = SKAction.sequence([addEmitterAction, wait, remove])
    
    run(sequence)
    
    player.removeFromParent()
    isGameOver = true
    
    showPlayAgainLabel()
  }
  
  func showPlayAgainLabel() {
    
    if playAgain == nil {
      playAgain = SKLabelNode(fontNamed: "Chalkduster")
      
      playAgain.text = "Play Again?"
      playAgain.name = "playAgain"
      playAgain.fontSize = 30
      playAgain.position = CGPoint(x: 512, y: 383)
      playAgain.horizontalAlignmentMode = .center
      playAgain.zPosition = 3
      playAgain.xScale = 0.001
      playAgain.yScale = 0.001
      addChild(playAgain)

      let playAgainAction = SKAction.scale(to: 1.0, duration: 0.5)
      playAgain.run(playAgainAction)
    }
    
  }
  
  @objc func restartGame() {
    for node in children {
      if node.name == "enemy" {
        node.removeFromParent()
      }
    }
    score = 0
    enemiesCreated = 0
    timerInterval = 1
    createPlayer()
    isGameOver = false
    
    playAgain.removeFromParent()
    playAgain = nil
  }
}
