//
//  GameScene.swift
//  MarbleRoll
//
//  Created by Alexander on 8/28/19.
//  Copyright © 2019 Dictality. All rights reserved.
//

import  CoreMotion
import SpriteKit

// Note: the numbers always double so they create a unique number when they are combined together
enum CollisionTypes: UInt32 {
  case player = 1
  case wall = 2
  case star = 4
  case vortex = 8
  case finish = 16
}

class GameScene: SKScene, SKPhysicsContactDelegate {
  var player: SKSpriteNode!
  let defaultPlayerPosition = CGPoint(x: 96, y: 672)
  var lastTouchPosition: CGPoint?
  var currentLevel = 1
  var loadingNextLevel = false
  
  var motionManager: CMMotionManager?
  var isGameOver = false
  
  var scoreLabel: SKLabelNode!
  var score = 0 {
    didSet {
      scoreLabel.text = "Score: \(score)"
    }
  }
  
  fileprivate func addBackground() {
    let background = SKSpriteNode(imageNamed: "background")
    background.position = CGPoint(x: 512, y: 384)
    background.blendMode = .replace
    background.zPosition = -1
    addChild(background)
  }
  
  fileprivate func addScoreLabel() {
    scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    scoreLabel.text = "Score: \(score)"
    scoreLabel.horizontalAlignmentMode = .left
    scoreLabel.position = CGPoint(x: 16, y: 16)
    scoreLabel.zPosition = 2
    addChild(scoreLabel)
  }
  
  override func didMove(to view: SKView) {
    
    scene?.scaleMode = .aspectFit
    
    loadLevel()
    addBackground()
    addScoreLabel()
    createPlayer(at: defaultPlayerPosition)
    
    physicsWorld.gravity = .zero
    physicsWorld.contactDelegate = self
    
    motionManager = CMMotionManager()
    motionManager?.startAccelerometerUpdates()
  }
  
  func loadLevel() {
    
    // Clear the scene
    removeChildren(in: children)
    
    guard let levelURL = Bundle.main.url(forResource: "level\(currentLevel)", withExtension: "txt") else { fatalError("Could not find level\(currentLevel).txt in the app bundle.") }
    guard let levelString = try? String(contentsOf: levelURL) else { fatalError("Could not load level1.txt from the app bundle") }
    
    let lines = levelString.components(separatedBy: "\n")
    
    for (row, line) in lines.reversed().enumerated() {
      
      for (column, letter) in line.enumerated() {
        let position = CGPoint(x: (64 * column) + 32, y: (64 * (row)) + 32)
        switch letter {
          case "x": createWall(at: position)
          case "v": createVortex(at: position)
          case "s": createStar(at: position)
          case "f": createFinish(at: position)
          case " ": break // this is an empty space - do nothing.
          default :  fatalError("Unknown level letter: '\(letter)'")
        }
      }
    }
  }
  
  func createWall(at position: CGPoint) {
    let node = SKSpriteNode(imageNamed: "block")
    node.position = position
    node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
    node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
    node.physicsBody?.isDynamic = false
    addChild(node)
  }
  
  func createVortex(at position: CGPoint) {
    let node = SKSpriteNode(imageNamed: "vortex")
    node.name = "vortex"
    node.position = position
    node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
    node.physicsBody?.isDynamic = false
    node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
    
    // Send a message on collision with player bitmask
    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
    // Don't bounce of anything
    node.physicsBody?.collisionBitMask = 0
    addChild(node)
  }
  
  func createStar(at position: CGPoint) {
    let node = SKSpriteNode(imageNamed: "star")
    node.name = "star"
    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
    node.physicsBody?.isDynamic = false
    node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
    node.physicsBody?.collisionBitMask = 0
    node.position = position
    addChild(node)
  }
  
  func createFinish(at position: CGPoint){
    let node = SKSpriteNode(imageNamed: "finish")
    node.name = "finish"
    node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
    node.physicsBody?.isDynamic = false
    node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
    node.physicsBody?.collisionBitMask = 0
    node.position = position
    addChild(node)
  }
  
  func createPlayer(at position: CGPoint) {
    player = SKSpriteNode(imageNamed: "player")
    player.position = position
    player.zPosition = 1
    
    player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
    player.physicsBody?.allowsRotation = false
    player.physicsBody?.linearDamping = 0.5
    player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
    player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue
    player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
    addChild(player)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let location = touch.location(in: self)
    lastTouchPosition = location
    
    // Check if next level node was pressed
    let nodesUnderTouch = nodes(at: location)
    for case let node as SKLabelNode in nodesUnderTouch where ["next level", "game over"].contains(node.name?.lowercased()) {
      isGameOver = true
      switch node.name?.lowercased() {
      case "next level": loadNextLevel()
      case "game over": restartGame()
      default: continue
      }
      break
    }
    
  }
  
  func restartGame() {
    currentLevel = 1
    loadLevel()
    addBackground()
    addScoreLabel()
    createPlayer(at: defaultPlayerPosition)
    physicsWorld.gravity = .zero
    player.physicsBody?.isDynamic = true
    isGameOver = false
  }
  
  func loadNextLevel() {
    loadingNextLevel = true
    loadLevel()
    addBackground()
    addScoreLabel()
    createPlayer(at: defaultPlayerPosition)
    physicsWorld.gravity = .zero
    player.physicsBody?.isDynamic = true
    isGameOver = false
    loadingNextLevel = false
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let location = touch.location(in: self)
    lastTouchPosition = location
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    lastTouchPosition = nil
  }
  
  override func update(_ currentTime: TimeInterval) {
    
    guard isGameOver == false else { return }
    
    #if targetEnvironment(simulator)
    if let lastTouchPosition = lastTouchPosition {
      let diff = CGPoint(x: lastTouchPosition.x - player.position.x, y: lastTouchPosition.y - player.position.y)
      physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
    }
    #else
    if let accelerometerData = motionManager?.accelerometerData {
      // accelerometer coordinates are fliped, since the device is rotated to landscape
      physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
    }
    #endif
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    guard let nodeA = contact.bodyA.node else { return }
    guard let nodeB = contact.bodyB.node else { return }
    if nodeA == player {
      playerCollided(with: nodeB)
    } else if nodeB == player {
        playerCollided(with: nodeA)
    }
  }
  
  func playerCollided(with node: SKNode) {
    if node.name == "vortex" {
      player.physicsBody?.isDynamic = false
      isGameOver = true
      score -= 1
      let move = SKAction.move(to: node.position, duration: 0.25)
      let scale = SKAction.scale(to: 0.0001, duration: 0.25)
      let remove = SKAction.removeFromParent()
      let sequence = SKAction.sequence([move, scale, remove])
      player.run(sequence) { [weak self] in
        self?.createPlayer(at: self!.defaultPlayerPosition)
        self?.isGameOver = false
      }
    } else if node.name == "star" {
      node.removeFromParent()
      score += 1
    } else if node.name == "finish" {
      
      // 0. Next Level
      currentLevel += 1
      
      // 1. Turn of players physics
      player.physicsBody?.isDynamic = false
      
      // 2. Center player on the finish node and create animation
      let moveAction = SKAction.move(to: node.position, duration: 0.5)
      let repeatScaleAction = SKAction.repeatForever(SKAction.sequence([
        SKAction.scale(to: 1.8, duration: 0.5),
        SKAction.scale(to: 1, duration: 0.5)])
      )
      let repeatRotateAction = SKAction.repeatForever(SKAction.rotate(byAngle: 6.28319, duration: 1))
      let group = SKAction.group([repeatScaleAction, repeatRotateAction])
      let sequence = SKAction.sequence([moveAction, group])
      player.run(sequence)
      
      // 3. Remove the finish node
      node.removeFromParent()
      
      // 4. Show next level node if next level is available
      let endLevelNode = SKLabelNode(fontNamed: "Chalkduster")
      endLevelNode.horizontalAlignmentMode = .center
      endLevelNode.fontSize = 50
      endLevelNode.position = CGPoint(x: scene!.size.width / 2, y: scene!.size.height / 2)
      endLevelNode.zPosition = 2
      
      if let _ = Bundle.main.url(forResource: "level\(currentLevel + 1)", withExtension: "txt") {
        endLevelNode.text = "NEXT LEVEL"
        endLevelNode.name = "Next Level"
        endLevelNode.fontColor = .green
      } else {
        endLevelNode.text = "GAME OVER"
        endLevelNode.name = "Game Over"
        endLevelNode.fontColor = .red
      }
      addChild(endLevelNode)
      
    }
  }
}
