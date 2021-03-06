//
//  GameScene.swift
//  Slice-A-Penguin
//
//  Created by Alexander on 7/8/19.
//  Copyright © 2019 Dictality. All rights reserved.
//

import AVFoundation
import SpriteKit

enum ForceBomb {
  case never, always, random
}

enum SequenceType: CaseIterable {
  case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain
}

class GameScene: SKScene {
  
  var gameScore: SKLabelNode!
  var score = 0 {
    didSet {
      gameScore.text = "Score: \(score)"
    }
  }
  
  var livesImages = [SKSpriteNode]()
  var lives = 3
  
  var gameOverLabel: SKLabelNode!
  var restartLabel: SKLabelNode!
  
  var activeSliceBG: SKShapeNode!
  var activeSliceFG: SKShapeNode!
  
  var activeSlicePoints = [CGPoint]()
  var isSwooshSoundActive = false
  var activeEnemies = [SKSpriteNode]()
  var bombSoundEffect: AVAudioPlayer?
  
  var popupTime = 0.9
  var sequence = [SequenceType]()
  var sequencePosition = 0
  var chainDelay = 3.0
  var nextSequenceQueued = true
  var isGameEnded = false
  var extraRarePopupCount = 0
  let extraRareLimit = 4
  
  //MARK: Game Constants
  let enemyXVelocityRangeFast = 8...15
  let enemyXVelocityRangeSlow = 3...5
  let enemyYVelocityRange = 24...32
  let enemyVelocityRangeMultiplier = 40
  
  override func didMove(to view: SKView) {
    let background = SKSpriteNode(imageNamed: "sliceBackground")
    background.position = CGPoint(x: 512, y: 384)
    background.blendMode = .replace
    background.zPosition = -1
    addChild(background)
    
    createScore()
    createLives()
    createSlices()
    
    startGame()
  }
  
  func startGame() {
    physicsWorld.gravity = CGVector(dx: 0, dy: -6)
    physicsWorld.speed = 0.85
    
    sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]
    
    for _ in 0...1000 {
      if let nextSequence = SequenceType.allCases.randomElement() {
        sequence.append(nextSequence)
      }
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
      self?.tossEnemies()
    }
    
  }
  
  func createScore() {
    gameScore = SKLabelNode(fontNamed: "Chalkduster")
    gameScore.horizontalAlignmentMode = .left
    gameScore.fontSize = 48
    addChild(gameScore)
    
    gameScore.position = CGPoint(x: 8, y: 8)
    score = 0
  }
  
  func createLives() {
    for i in 0 ..< 3 {
      let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
      spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
      addChild(spriteNode)
      livesImages.append(spriteNode)
    }
  }
  
  func createSlices() {
    activeSliceBG = SKShapeNode()
    activeSliceBG.zPosition = 2
    
    activeSliceFG = SKShapeNode()
    activeSliceFG.zPosition = 3
    
    activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
    activeSliceBG.lineWidth = 9
    activeSliceFG.strokeColor = .white
    activeSliceFG.lineWidth = 5
    
    addChild(activeSliceBG)
    addChild(activeSliceFG)
  }
  
  func createEnemy(forceBomb: ForceBomb = .random) {
    let enemy: SKSpriteNode
    
    var enemyType = Int.random(in: 0...6)
    
    // Apply Extra Rare Filter
    if enemyType == 6 {
      if extraRarePopupCount < extraRareLimit {
          enemyType = Int.random(in: 0...5)
          extraRarePopupCount = extraRarePopupCount + 1
      } else {
        extraRarePopupCount = 0
      }
    }
    
    if forceBomb == .never {
      enemyType = 1
    } else if forceBomb == .always {
      enemyType = 0
    }
    
    // If Bomb
    if enemyType == 0 {
      enemy = SKSpriteNode()
      enemy.zPosition = 1
      enemy.name = "bombContainer"
      
      // Create bomb node
      let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
      bombImage.name = "bomb"
      enemy.addChild(bombImage)
      
      if bombSoundEffect != nil {
        bombSoundEffect?.stop()
        bombSoundEffect = nil
      }
      
      // Add fuse sound
      if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
        if let sound = try? AVAudioPlayer(contentsOf: path) {
          bombSoundEffect = sound
          sound.play()
        }
      }
      
      // Add fuse emitter
      if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
        emitter.position = CGPoint(x: 76, y: 64)
        enemy.addChild(emitter)
      }
      
    }
    else if enemyType == 6 {
      enemy = SKSpriteNode(imageNamed: "alien")
      run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
      enemy.name = "xtra"
    }
      // If Penguin
    else {
      enemy = SKSpriteNode(imageNamed: "penguin")
      run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
      enemy.name = "enemy"
    }
    
    let randomPosition = CGPoint(x: Int.random(in: 64...960), y: -128)
    enemy.position = randomPosition
    
    let randomAngularVelocity = CGFloat.random(in: -3...3)
    let randomXVelocity: Int
    
    if randomPosition.x < 256 {
      randomXVelocity = Int.random(in: enemyXVelocityRangeFast)
    } else if randomPosition.x < 512 {
      randomXVelocity = Int.random(in: enemyXVelocityRangeSlow)
    } else if randomPosition.x < 768 {
      randomXVelocity = -Int.random(in: enemyXVelocityRangeSlow)
    } else {
      randomXVelocity = -Int.random(in: enemyXVelocityRangeFast)
    }
    
    let randomYVelocity = Int.random(in: enemyYVelocityRange)
    
    enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
    enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * enemyVelocityRangeMultiplier, dy: randomYVelocity * enemyVelocityRangeMultiplier)
    enemy.physicsBody?.angularVelocity = randomAngularVelocity
    enemy.physicsBody?.collisionBitMask = 0
    
    addChild(enemy)
    activeEnemies.append(enemy)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard isGameEnded == false else { return }
    
    guard let touch = touches.first else { return }
    let location = touch.location(in: self)
    activeSlicePoints.append(location)
    redrawActiveSlice()
    
    if !isSwooshSoundActive {
      playSwooshSound()
    }
    
    let nodesAtPoint = nodes(at: location)
    
    for case let node as SKSpriteNode in nodesAtPoint {
      if node.name == "enemy" {
        // destroy the penguin
        if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
          emitter.position = node.position
          addChild(emitter)
        }
        
        node.name = ""  // removes from counting towards points on next update call
        node.physicsBody?.isDynamic = false // turns off physics
        
        let scaleOut = SKAction.scale(by: 0.001, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let group = SKAction.group([scaleOut, fadeOut])
        
        let seq = SKAction.sequence([group, .removeFromParent()])
        node.run(seq)
        
        score += 1
        
        if let index = activeEnemies.firstIndex(of: node) {
          activeEnemies.remove(at: index)
        }
        run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
        
      }
      else if node.name == "xtra" {
          // Extra Points
          if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
            emitter.position = node.position
            addChild(emitter)
          }
          
          node.name = ""  // removes from counting towards points on next update call
          node.physicsBody?.isDynamic = false // turns off physics
          
          let scaleOut = SKAction.scale(by: 0.001, duration: 0.2)
          let fadeOut = SKAction.fadeOut(withDuration: 0.2)
          let group = SKAction.group([scaleOut, fadeOut])
          
          let seq = SKAction.sequence([group, .removeFromParent()])
          node.run(seq)
          
          score += 10
          
          if let index = activeEnemies.firstIndex(of: node) {
            activeEnemies.remove(at: index)
          }
          run(SKAction.playSoundFileNamed("hitBonus.wav", waitForCompletion: false))
          
        }
        else if node.name == "bomb" {
        // destroy the bomb
        guard let bombContainer = node.parent as? SKSpriteNode else { continue }
        
        if let emitter = SKEmitterNode(fileNamed: "sliceHitBomb") {
          emitter.position = bombContainer.position
          addChild(emitter)
        }
        
        node.name = ""  // removes from counting towards points on next update call
        bombContainer.physicsBody?.isDynamic = false // turns off physics
        
        let scaleOut = SKAction.scale(by: 0.001, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let group = SKAction.group([scaleOut, fadeOut])
        
        let seq = SKAction.sequence([group, .removeFromParent()])
        bombContainer.run(seq)
        
        if let index = activeEnemies.firstIndex(of: bombContainer) {
          activeEnemies.remove(at: index)
        }
        
        run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
        endGame(triggeredByBomb: true)
        
      }
    }
    
  }
  
  func endGame(triggeredByBomb: Bool) {
    guard isGameEnded == false else { return }
    
    isGameEnded = true
    physicsWorld.speed = 0
    //isUserInteractionEnabled = false
    
    bombSoundEffect?.stop()
    bombSoundEffect = nil
    
    if triggeredByBomb {
      livesImages[0].texture = SKTexture(imageNamed: "sliceLifeGone")
      livesImages[1].texture = SKTexture(imageNamed: "sliceLifeGone")
      livesImages[2].texture = SKTexture(imageNamed: "sliceLifeGone")
    }
    
    gameOver()
  }
  
  func gameOver() {
    gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
    gameOverLabel.zPosition = 10
    gameOverLabel.fontColor = .red
    gameOverLabel.text = "GAME OVER"
    gameOverLabel.fontSize = 50
    gameOverLabel.setScale(0.1)
    gameOverLabel.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
    
    addChild(gameOverLabel)
    
    restartLabel = SKLabelNode(fontNamed: "Chalkduster")
    restartLabel.zPosition = 10
    restartLabel.fontColor = .green
    restartLabel.text = "tap to play again"
    restartLabel.fontSize = 30
    restartLabel.setScale(0.1)
    restartLabel.position = CGPoint(x: frame.width / 2, y: frame.height / 2 - 50)
    
    addChild(restartLabel)
    
    let seq = SKAction.sequence([SKAction.scale(to: 1.3, duration: 0.3), SKAction.scale(to: 1, duration: 0.15)])
    gameOverLabel.run(seq)
    
    let seq2 = SKAction.sequence([SKAction.scale(to: 1.3, duration: 1), SKAction.scale(to: 1, duration: 1)])
    restartLabel.run(SKAction.repeatForever(seq2))
  }
  
  func restartGame() {
    if isGameEnded {
      isGameEnded = false
      score = 0
      lives = 3
      
      // Cancel: DispatchQueue.main.asyncAfter(deadline: .now() + 2) from previous run before creating a new one.
      
      activeEnemies.removeAll(keepingCapacity: true)
      gameOverLabel.removeFromParent()
      restartLabel.removeFromParent()
      gameOverLabel = nil
      restartLabel = nil
      
      livesImages = livesImages.map{$0.texture = SKTexture(imageNamed: "sliceLife"); return $0}
      
      startGame()
      
    }
  }
  
  func playSwooshSound() {
    isSwooshSoundActive = true
    
    let randomNumber = Int.random(in: 1...3)
    let soundName = "swoosh\(randomNumber).caf"
    
    let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
    
    run(swooshSound) { [weak self] in
      self?.isSwooshSoundActive = false
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
    activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let location = touch.location(in: self)
    let nodesAtPoint = nodes(at: location)
    
    if isGameEnded {
      if (gameOverLabel != nil && gameOverLabel != nil) && nodesAtPoint.contains(gameOverLabel) || nodesAtPoint.contains(restartLabel) {
        restartGame()
      }
    }
    
    activeSlicePoints.removeAll(keepingCapacity: true)
    activeSlicePoints.append(location)
    
    redrawActiveSlice()
    
    activeSliceBG.removeAllActions()
    activeSliceFG.removeAllActions()
    
    activeSliceBG.alpha = 1
    activeSliceFG.alpha = 1
  }
  
  func redrawActiveSlice() {
    if activeSlicePoints.count < 2 {
      activeSliceBG.path = nil
      activeSliceFG.path = nil
      return
    }
    
    if activeSlicePoints.count > 12 {
      activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
    }
    
    let path = UIBezierPath()
    path.move(to: activeSlicePoints[0])
    
    for i in 1 ..< activeSlicePoints.count {
      path.addLine(to: activeSlicePoints[i])
    }
    
    activeSliceBG.path = path.cgPath
    activeSliceFG.path = path.cgPath
  }
  
  func subtractLife() {
    lives -= 1
    
    run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
    
    var life: SKSpriteNode
    
    if lives == 2 {
      life = livesImages[0]
    } else if lives == 1 {
      life = livesImages[1]
    } else {
      life = livesImages[2]
      endGame(triggeredByBomb: false)
    }
    
    life.texture = SKTexture(imageNamed: "sliceLifeGone")
    life.xScale = 1.3
    life.yScale = 1.3
    life.run(SKAction.scale(by: 1, duration: 0.1))
  }
  
  override func update(_ currentTime: TimeInterval) {
    if activeEnemies.count > 0 {
      for (index, node) in activeEnemies.enumerated().reversed() {
        if node.position.y < -140 {
          node.removeAllActions()
          
          if node.name == "enemy" {
            node.name = ""
            subtractLife()
            
            node.removeFromParent()
            activeEnemies.remove(at: index)
          }
          else if node.name == "xtra" {
            node.name = ""
            node.removeFromParent()
          }
          else if node.name == "bombContainer" {
            node.name = ""
            node.removeFromParent()
            activeEnemies.remove(at: index)
          }
        }
      }
    } else {
      if !nextSequenceQueued {
        DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [weak self] in
          self?.tossEnemies()
        }
        nextSequenceQueued = true
      }
    }
    
    var bombCount = 0
    
    for node in activeEnemies {
      if node.name == "bombContainer" {
        bombCount += 1
        break
      }
    }
    
    if bombCount == 0 {
      // no bomb - stop the fuse sound!
      bombSoundEffect?.stop()
      bombSoundEffect = nil
    }
  }
  
  func tossEnemies() {
    guard isGameEnded == false else { return }
    
    popupTime *= 0.991
    chainDelay *= 0.99
    physicsWorld.speed *= 1.02
    
    let sequenceType = sequence[sequencePosition]
    
    switch sequenceType {
    case .oneNoBomb:
      createEnemy(forceBomb: .never)
    
    case .one:
      createEnemy()
    
    case .twoWithOneBomb:
      createEnemy(forceBomb: .never)
      createEnemy(forceBomb: .always)
    
    case .two:
      createEnemy()
      createEnemy()
    
    case .three:
      createEnemy()
      createEnemy()
      createEnemy()
      
    case .four:
      createEnemy()
      createEnemy()
      createEnemy()
      createEnemy()
      
    case .chain:
      createEnemy()
      
      DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0)) { [weak self] in self?.createEnemy()
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 2)) { [weak self] in self?.createEnemy()
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 3)) { [weak self] in self?.createEnemy()
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 4)) { [weak self] in self?.createEnemy()
      }
      
    case .fastChain:
      createEnemy()
      
      DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0)) { [weak self] in self?.createEnemy()
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 2)) { [weak self] in self?.createEnemy()
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 3)) { [weak self] in self?.createEnemy()
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 4)) { [weak self] in self?.createEnemy()
      }
    }
    
    sequencePosition += 1
    nextSequenceQueued = false
  }
  
}
