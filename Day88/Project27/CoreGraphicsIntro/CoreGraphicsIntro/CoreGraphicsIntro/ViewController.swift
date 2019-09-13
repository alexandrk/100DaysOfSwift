//
//  ViewController.swift
//  CoreGraphics
//
//  Created by Alexander on 9/9/19.
//  Copyright © 2019 Dictality. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var imageView: UIImageView!
  var currentDrawType = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()

    redrawTapped("")
  }

  @IBAction func redrawTapped(_ sender: Any) {
    currentDrawType += 1
    
    if currentDrawType > 5 {
      currentDrawType = 0
    }
    
    switch currentDrawType {
    case 0:
      drawRectangle()
    case 1:
      drawCircle()
    case 2:
      drawCheckerboard()
    case 3:
      drawRotatedSquares()
    case 4:
      drawLines()
    case 5:
      drawImagesAndText()
    default:
      break
    }
    
  }
  
  func drawRectangle() {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
    
    let image = renderer.image { ctx in
      // drawing code
      let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)
      ctx.cgContext.setFillColor(UIColor.red.cgColor)
      ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
      ctx.cgContext.setLineWidth(10)
      
      ctx.cgContext.addRect(rectangle)
      ctx.cgContext.drawPath(using: .fillStroke)
    }
    
    imageView.image = image
  }
  
  func drawCircle() {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
    
    let image = renderer.image { ctx in
      // drawing code
      let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)
      ctx.cgContext.setFillColor(UIColor.red.cgColor)
      ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
      ctx.cgContext.setLineWidth(10)
      
      ctx.cgContext.addEllipse(in: rectangle)
      ctx.cgContext.drawPath(using: .fillStroke)
    }
  
    imageView.image = image
    
  }
    
  func drawCheckerboard() {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
    
    let image = renderer.image { ctx in
      // drawing code
      
      for row in 0 ..< 8 {
        for col in 0 ..< 8 {
          if (row + col).isMultiple(of: 2) {
            ctx.cgContext.fill(CGRect(x: col * 64, y: row * 64, width: 64, height: 64))
          }
        }
      }
      
    }
    
    imageView.image = image
  }
  
  func drawRotatedSquares() {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
    
    let image = renderer.image { ctx in
      // drawing code
      ctx.cgContext.translateBy(x: 256, y: 256)
      
      let rotations = 16
      let amount = Double.pi / Double(rotations)
      
      for _ in 0 ..< rotations {
        ctx.cgContext.rotate(by: CGFloat(amount))
        ctx.cgContext.addRect(CGRect(x: -128, y: -128, width: 256, height: 256))
      }
      
      ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
      ctx.cgContext.strokePath()
    }
    
    imageView.image = image
  }
  
  func drawLines() {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
    
    let image = renderer.image { ctx in
      // drawing code
      
      var first = true
      var length: CGFloat = 256
      
      // draw rectangle (frame of imageContext)
      let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)
      ctx.cgContext.setFillColor(UIColor.red.cgColor)
      ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
      ctx.cgContext.setLineWidth(10)
      
      ctx.cgContext.addRect(rectangle)
      ctx.cgContext.drawPath(using: .fillStroke)
      
      ctx.cgContext.translateBy(x: 256, y: 256)
      ctx.cgContext.setLineWidth(1)
      
      for _ in 0 ..< 256 {
        ctx.cgContext.rotate(by: .pi / 2)
        
        if first {
          ctx.cgContext.move(to: CGPoint(x: length, y: 50))
          first = false
        } else {
          ctx.cgContext.addLine(to: CGPoint(x: length, y: 50))
        }
        
        length *= 0.99
      }
      
      ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
      ctx.cgContext.strokePath()
    }
    
    imageView.image = image
  }
  
  func drawImagesAndText() {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
    
    let img = renderer.image { ctx in
      
      ctx.cgContext.addRect(CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 512, height: 512)))
      ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
      ctx.cgContext.setLineWidth(10)
      ctx.cgContext.strokePath()
      
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.alignment = .left
      
      let attrs: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 36),
        .paragraphStyle: paragraphStyle
      ]
      
      let string = "London is the capital of Great Britain."
      let attributedString = NSAttributedString(string: string, attributes: attrs)
      
      attributedString.draw(with: CGRect(x: 32, y: 32, width: 448, height: 488), options: .usesLineFragmentOrigin, context: nil)
      
      let mouse = UIImage(named: "mouse")
      mouse?.draw(at: CGPoint(x: 300, y: 150))
    }
    
    imageView.image = img
  }
  
}

