//
//  GameScene.swift
//  Peggle
//
//  Created by Alexander Kazakov on 4/19/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  var ballsLabel: SKLabelNode!
  var scoreLabel: SKLabelNode!
  
  var score = 0 {
    didSet {
      scoreLabel.text = "Score: \(score)"
    }
  }
  
  var balls = 5 {
    didSet {
      ballsLabel.text = "Balls: \(balls)"
    }
  }
  
  var editLabel: SKLabelNode!
  
  var editingMode: Bool = false {
    didSet {
      if editingMode {
        editLabel.text = "Done"
      } else {
        editLabel.text = "Edit"
        balls = 5
      }
    }
  }
  
  override func didMove(to view: SKView) {
    let background = SKSpriteNode(imageNamed: "background")
    background.position = CGPoint(x: 512, y: 384)
    background.blendMode = .replace
    background.zPosition = -1
    addChild(background)
    
    scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    scoreLabel.text = "Score: 0"
    scoreLabel.horizontalAlignmentMode = .right
    scoreLabel.position = CGPoint(x: 980, y: 700)
    addChild(scoreLabel)
    
    ballsLabel = SKLabelNode(fontNamed: "Chalkduster")
    ballsLabel.text = "Balls: 5"
    ballsLabel.horizontalAlignmentMode = .right
    ballsLabel.position = CGPoint(x: 780, y: 700)
    addChild(ballsLabel)
    
    editLabel = SKLabelNode(fontNamed: "Chalkduster")
    editLabel.text = "Edit"
    editLabel.position = CGPoint(x: 80, y: 700)
    addChild(editLabel)
    
    physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    physicsWorld.contactDelegate = self
    
    makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
    makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
    makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
    makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
    
    makeBouncer(at: CGPoint(x: 0, y: 0))
    makeBouncer(at: CGPoint(x: 256, y: 0))
    makeBouncer(at: CGPoint(x: 512, y: 0))
    makeBouncer(at: CGPoint(x: 768, y: 0))
    makeBouncer(at: CGPoint(x: 1024, y: 0))
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    var location = touch.location(in: self)
    let object = nodes(at: location)
    
    if object.contains(editLabel) {
      editingMode.toggle()
    } else {
      
      if editingMode {
        let size = CGSize(width: Int.random(in: 16...128), height: 16)
        let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
        box.zRotation = CGFloat.random(in: 0...3)
        box.position = location
        box.name = "obstacle"
        
        box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
        box.physicsBody?.isDynamic = false
        addChild(box)
      } else {
        
        if balls > 0 {
        
          balls -= 1
          
          // Restrict the location of the ball to top 3rd of the screen
          if location.y < view!.bounds.height * (2/3) {
            location.y = view!.bounds.height * (2/3)
          }
          
          let colors: [String] = ["Blue", "Red", "Cyan", "Green", "Grey", "Yellow", "Purple"]
          let ball = SKSpriteNode(imageNamed: "ball\(colors.randomElement() ?? "")")
          ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
          ball.physicsBody!.restitution = 0.8
          ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
          ball.position = location
          ball.name = "ball"
          addChild(ball)
        } else {
          print("No balls left.")
        }
      }
      
    }
  }
  
  func makeBouncer(at position: CGPoint) {
    let bouncer = SKSpriteNode(imageNamed: "bouncer")
    bouncer.position = position
    bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
    bouncer.physicsBody?.isDynamic = false
    addChild(bouncer)
  }
  
  func makeSlot(at position: CGPoint, isGood: Bool) {
    var slotBase: SKSpriteNode
    var slotGlow: SKSpriteNode
    
    if (isGood) {
      slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
      slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
      slotBase.name = "good"
    } else {
      slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
      slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
      slotBase.name = "bad"
    }
    
    slotBase.position = position
    slotGlow.position = position
    
    slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
    slotBase.physicsBody?.isDynamic = false
    
    addChild(slotBase)
    addChild(slotGlow)
    
    let spin = SKAction.rotate(byAngle: .pi, duration: 10)
    let spinForever = SKAction.repeatForever(spin)
    slotGlow.run(spinForever)
  }
  
  func collision(between ball: SKNode, object: SKNode) {
    if object.name == "good" {
      destroy(ball: ball)
      score += 1
      balls += 1
    } else if object.name == "bad" {
      destroy(ball: ball)
      score -= 1
    } else if object.name == "obstacle" {
      destroy(obstacle: object)
    }
  }
  
  func destroy(ball: SKNode) {
    if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
      fireParticles.position = ball.position
      addChild(fireParticles)
    }
    
    ball.removeFromParent()
  }
  
  func destroy(obstacle: SKNode) {
    obstacle.removeFromParent()
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    
    guard let nodeA = contact.bodyA.node else { return }
    guard let nodeB = contact.bodyB.node else { return }
    
    if nodeA.name == "ball" {
      collision(between: nodeA, object: nodeB)
    } else if nodeB.name == "ball" {
      collision(between: nodeB, object: nodeA)
    }
  }
  
}

// TODO: Add levels (preposition obsticles randomly)
// TODO: Make a better reset for when the player rans out of balls
// TODO: Have some info screens
// TODO: Change scoring system (points for removing obstacles, maybe if the ball falls into the green  pit at the end?)
