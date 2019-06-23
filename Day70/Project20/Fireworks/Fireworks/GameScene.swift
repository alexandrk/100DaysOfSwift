//
//  GameScene.swift
//  Fireworks
//
//  Created by Alexander on 6/19/19.
//  Copyright © 2019 Dictality. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
  
  var gameTimer: Timer?
  var fireworks = [SKNode]()
  
  let finiteNumberOfLaunches = 3
  var launchesTotal = 0
  let leftEdge = -22
  let bottomEdge = -22
  let rightEdge = 1024 + 22
  
  var gameOverLabel: SKLabelNode!
  var restartLabel: SKLabelNode!
  var isGameOver = false
  
  var scoreLabel: SKLabelNode!
  var score = 0 {
    didSet {
      scoreLabel.text = "Score: \(score)"
    }
  }
  
  override func didMove(to view: SKView) {
    let background = SKSpriteNode(imageNamed: "background")
    background.position = CGPoint(x: 512, y: 384)
    background.blendMode = .replace
    background.zPosition = -1
    addChild(background)
    
    scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    scoreLabel.horizontalAlignmentMode = .left
    scoreLabel.text = "Score: 0"
    scoreLabel.fontSize = 50
    scoreLabel.zPosition = 10
    scoreLabel.position = CGPoint(x: 8, y: 8)
    addChild(scoreLabel)
    
    gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    
  }
  
  func createFirework(xMovement: CGFloat, x: Int, y: Int) {
    let node = SKNode()
    node.position = CGPoint(x: x, y: y)
    
    let firework = SKSpriteNode(imageNamed: "rocket")
    firework.colorBlendFactor = 1
    firework.name = "firework"
    node.addChild(firework)
    
    switch Int.random(in: 0...2) {
    case 0:
      firework.color = .cyan
    case 1:
      firework.color = .green
    case 2:
      firework.color = .red
    default:
      firework.color = .red
    }
    
    let path = UIBezierPath()
    path.move(to: .zero)
    path.addLine(to: CGPoint(x: xMovement, y: 1000))
    
    let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
    node.run(move)
    
    if let emitter = SKEmitterNode(fileNamed: "fuse") {
      emitter.position = CGPoint(x: 0, y: -22)
      node.addChild(emitter)
    }
    
    fireworks.append(node)
    addChild(node)
  }
  
  @objc func launchFireworks() {
    let movementAmount: CGFloat = 1800
    launchesTotal += 1
    
    switch Int.random(in: 0...3) {
    case 0:
      //fire five, straight up
      createFirework(xMovement: 0, x: 512, y: bottomEdge)
      createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
      createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
      createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
      createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)
    case 1:
      //fire five, in a fan
      createFirework(xMovement: 0, x: 512, y: bottomEdge)
      createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
      createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
      createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
      createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)
    case 2:
      // fire five, from the left to the right
      createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
      createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
      createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
      createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
      createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)
    case 3:
      // fire five, from the right to the left
      createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
      createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
      createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
      createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
      createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)
    default:
      break
    }
  }
  
  func checkTouches(_ touches: Set<UITouch>) {
    guard let touch = touches.first else { return }
    
    if isGameOver {
      restartGame()
    }
    
    let location = touch.location(in: self)
    let nodesAtPoint = nodes(at: location)
    
    for case let node as SKSpriteNode in nodesAtPoint {
      guard node.name == "firework" else { continue }
      
      for parent in fireworks {
        guard let firework = parent.children.first as? SKSpriteNode else { continue }
        
        if firework.name == "selected" && firework.color != node.color {
          firework.name = "firework"
          firework.colorBlendFactor = 1
        }
      }
      
      node.name = "selected"
      node.colorBlendFactor = 0
    }
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    checkTouches(touches)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)
    checkTouches(touches)
  }
  
  override func update(_ currentTime: TimeInterval) {
    
    if launchesTotal > finiteNumberOfLaunches && !isGameOver {
      gameOver()
    }
    
    for (index, firework) in fireworks.enumerated().reversed() {
      if firework.position.y > 900 {
        fireworks.remove(at: index)
        firework.removeFromParent()
      }
    }
  }
  
  func explode(firework: SKNode) {
    if let emitter = SKEmitterNode(fileNamed: "explode") {
      emitter.position = firework.position
      emitter.run(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.removeFromParent()]))
      addChild(emitter)
    }
    firework.removeFromParent()
  }
  
  func explodeFireworks() {
    var numExploded = 0
    
    for (index, fireworkContainer) in fireworks.enumerated().reversed() {
      guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }
      
      if firework.name == "selected" {
        explode(firework: fireworkContainer)
        fireworks.remove(at: index)
        numExploded += 1
      }
      
      switch numExploded {
      case 0: break
      case 1: score += 200
      case 2: score += 500
      case 3: score += 1500
      case 4: score += 2500
      default: score += 4000
      }
      
    }
  }
  
  func gameOver() {
    // Check if GameOver logic is already initiated.
    guard !isGameOver else { return }
    
    gameTimer?.invalidate()
    
    gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
    gameOverLabel.fontColor = .red
    gameOverLabel.text = "GAME OVER"
    gameOverLabel.fontSize = 50
    gameOverLabel.zPosition = 10
    gameOverLabel.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
    addChild(gameOverLabel)
    
    restartLabel = SKLabelNode(fontNamed: "Chalkduster")
    restartLabel.text = "tap anywhere to restart"
    restartLabel.fontSize = 40
    restartLabel.zPosition = 10
    restartLabel.position = CGPoint(x: frame.width / 2, y: frame.height / 2 - 80)
    addChild(restartLabel)
    
    isGameOver = true
  }
  
  func restartGame() {
    isGameOver = false
    launchesTotal = 0
    gameOverLabel.removeFromParent()
    restartLabel.removeFromParent()
    score = 0
    gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
  }
  
}
