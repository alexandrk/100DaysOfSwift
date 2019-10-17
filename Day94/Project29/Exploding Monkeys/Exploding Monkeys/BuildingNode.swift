//
//  BuildingNode.swift
//  Exploding Monkeys
//
//  Created by Alexander on 10/9/19.
//  Copyright © 2019 Dictality. All rights reserved.
//

import SpriteKit
import UIKit

class BuildingNode: SKSpriteNode {
  var currentImage: UIImage!
  
  func setup() {
    name = "building"
    
    currentImage = drawBuilding(size: size)
    texture = SKTexture(image: currentImage)
    configurePhysics(update: false)
  }
  
  func configurePhysics(update: Bool) {
    if update { physicsBody = nil }

    // LOOKS LIKE THE BUG IS FIXED IN XCODE 10.2 beta NOPE
    // There is an unknown issue with SKTexture returning a plank texture when created from the currentImage in the simulator
    // This code allows for multiple attempts to be made
    var count = 0
    while physicsBody == nil && count < 300 {
      count += 1
      physicsBody = SKPhysicsBody(texture: texture!, size: size)
      
      // Use generic images, if unable to create custom ones for buildings. (Should be in simulator only)
      if count % 50 == 0 {
        print("Physics Body not created after: \(count) attempts.")
        texture = SKTexture(imageNamed: "exampleBuilding\(Int.random(in: 1...2))")
        continue
      }
      
      if physicsBody == nil && !update {
        currentImage = drawBuilding(size: size)
        texture = SKTexture(image: currentImage)
      } else if physicsBody == nil && update {
        print("Unable to update physics body.")
      }
      else if count == 1 {
        // Do nothing, everything is normal
      } else {
        print("Physics Body created on: \(count) attempt.")
      }
    }
    
    physicsBody!.isDynamic = false
    physicsBody!.categoryBitMask = CollisionTypes.building.rawValue
    physicsBody!.contactTestBitMask = CollisionTypes.banana.rawValue
  }
  
  func drawBuilding(size: CGSize) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: size)
    let img = renderer.image { ctx in
      let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
      
      let color: UIColor

      switch Int.random(in: 0...2) {
        case 0: color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
        case 1: color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
        default: color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
      }

      color.setFill()
      ctx.cgContext.addRect(rectangle)
      ctx.cgContext.drawPath(using: .fill)

      let lightOnColor = UIColor(hue: 0.19, saturation: 0.67, brightness: 0.99, alpha: 1)
      let lightOffColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)

      for row in stride(from: 10, to: Int(size.height - 10), by: 40) {
        for col in stride(from: 10, through: Int(size.width - 10), by: 40) {
          if Bool.random() {
            lightOnColor.setFill()
          } else {
            lightOffColor.setFill()
          }
          ctx.cgContext.fill(CGRect(x: col, y: row, width: 15, height: 20))
        }
      }
    }
    return img
  }
  
  func hit(at point: CGPoint) {
    let convertedPoint = CGPoint(x: point.x + size.width / 2, y: abs(point.y - (size.height / 2)))
    
    let renderer = UIGraphicsImageRenderer(size: size)
    let img = renderer.image { ctx in
      currentImage.draw(at: .zero)
      
      ctx.cgContext.addEllipse(in: CGRect(x: convertedPoint.x - 32, y: convertedPoint.y - 32, width: 64, height: 64))
      ctx.cgContext.setBlendMode(.clear)
      ctx.cgContext.drawPath(using: .fill)
    }
    
    texture = SKTexture(image: img)
    
    currentImage = img
    configurePhysics(update: true)
  }
  
}
