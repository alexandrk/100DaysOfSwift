//
//  GameViewController.swift
//  Exploding Monkeys
//
//  Created by Alexander on 10/9/19.
//  Copyright © 2019 Dictality. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
  var currentGame: GameScene?
  
  @IBOutlet weak var angleSlider: UISlider!
  @IBOutlet weak var angleLabel: UILabel!
  @IBOutlet weak var velocitySlider: UISlider!
  @IBOutlet weak var velocityLabel: UILabel!
  @IBOutlet weak var launchButton: UIButton!
  @IBOutlet weak var wind: UILabel!
  @IBOutlet weak var player1Score: UILabel!
  @IBOutlet weak var player2Score: UILabel!
  
  override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                currentGame = scene as? GameScene
                currentGame?.viewController = self
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    
      angleChanged(self)
      velocityChanged(self)
      activatePlayer(number: 1)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
  
  @IBAction func angleChanged(_ sender: Any) {
    angleLabel.text = "Angle: \(Int(angleSlider.value))°"
  }
  
  @IBAction func velocityChanged(_ sender: Any) {
    velocityLabel.text = "Velocity: \(Int(velocitySlider.value))"
  }
  
  @IBAction func launch(_ sender: Any) {
    angleSlider.isHidden = true
    angleLabel.isHidden = true
    velocitySlider.isHidden = true
    velocityLabel.isHidden = true
    launchButton.isHidden = true
    currentGame?.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value))
  }
  
  func activatePlayer(number: Int) {
    if number == 1 {
      player1Score.font = UIFont.boldSystemFont(ofSize: player1Score.font.pointSize + 3)
      player2Score.font = UIFont.systemFont(ofSize: player2Score.font.pointSize - 3)
    } else {
      player1Score.font = UIFont.systemFont(ofSize: player1Score.font.pointSize - 3)
      player2Score.font = UIFont.boldSystemFont(ofSize: player2Score.font.pointSize + 3)
    }
    angleSlider.isHidden = false
    angleLabel.isHidden = false
    velocitySlider.isHidden = false
    velocityLabel.isHidden = false
    launchButton.isHidden = false
  }
  
}
