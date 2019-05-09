//
//  WhackSlot.swift
//  Whack-a-Penguin
//
//  Created by Alexander Kazakov on 5/8/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import SpriteKit
import UIKit

class WhackSlot: SKNode {
  var charNode: SKSpriteNode!
  
  var mudEmitter: SKEmitterNode!
  
  var isVisible = false
  var isHit = false
  
  func configure(at position: CGPoint) {
    self.position = position
    
    let sprite = SKSpriteNode(imageNamed: "whackHole")
    
    mudEmitter = SKEmitterNode(fileNamed: "Mud")!
    mudEmitter.zPosition = 2
    sprite.addChild(mudEmitter)
    
    addChild(sprite)
    
    let cropNode = SKCropNode()
    cropNode.position = CGPoint(x: 0, y: 15)
    cropNode.zPosition = 1
    cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")
    
    charNode = SKSpriteNode(imageNamed: "penguinGood")
    charNode.position = CGPoint(x: 0, y: -90)
    charNode.name = "character"
    cropNode.addChild(charNode)
    
    addChild(cropNode)
  }
  
  func show(hideTime: Double) {
    if isVisible { return }
    
    charNode.xScale = 1
    charNode.yScale = 1
    
    charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
    mudEmitter.resetSimulation()
    
    isVisible = true
    isHit = false
    
    if Int.random(in: 0...2) == 0 {
      charNode.texture = SKTexture(imageNamed: "penguinGood")
      charNode.name = "charFriend"
    } else {
      charNode.texture = SKTexture(imageNamed: "penguinEvil")
      charNode.name = "charEnemy"
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + (hideTime * 3.5)) { [weak self] in
      self?.hide()
    }
  }
  
  func hide() {
    if !isVisible { return }
    
    //mudEmitter.resetSimulation()
    charNode.run(SKAction.moveBy(x: 0, y: -80, duration: 0.15))
    isVisible = false
  }
  
  func hit() {
    isHit = true
    
    guard let smoke = SKEmitterNode(fileNamed: "Smoke") else { return }
    smoke.position = charNode.position
    smoke.zPosition = 2
    
    let smokeAction = SKAction.sequence([
      SKAction.run { [weak self] in self?.addChild(smoke) },
      SKAction.wait(forDuration: 1),
      SKAction.run { smoke.removeFromParent() }])
    
    run(smokeAction)
    
    let delay = SKAction.wait(forDuration: 0.25)
    let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
    let notVisible = SKAction.run { [weak self] in
      self?.isVisible = false
    }
    let sequence = SKAction.sequence([delay, hide, notVisible])
    charNode.run(sequence)
  }
}
