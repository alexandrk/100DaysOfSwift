//
//  ViewController.swift
//  Project 2
//
//  Created by Alexander Kazakov on 3/19/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var button1: UIButton!
  @IBOutlet weak var button2: UIButton!
  @IBOutlet weak var button3: UIButton!
  
  var countries = [String]()
  var score = 0
  var correctAnswer = 0
  var numberOfQuestionsAsked = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]

    button1.layer.borderWidth = 1
    button2.layer.borderWidth = 1
    button3.layer.borderWidth = 1
    
    button1.layer.borderColor = UIColor.lightGray.cgColor
    button2.layer.borderColor = UIColor.lightGray.cgColor
    button3.layer.borderColor = UIColor.lightGray.cgColor
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SCORE", style: .plain, target: self, action: #selector(showCurrentScore))
    
    askQuestion()
  }

  func askQuestion(action: UIAlertAction! = nil) {
    
    numberOfQuestionsAsked += 1
    
    countries.shuffle()
    correctAnswer = Int.random(in: 0...2)
    
    button1.setImage(UIImage(named: countries[0]), for: .normal)
    button2.setImage(UIImage(named: countries[1]), for: .normal)
    button3.setImage(UIImage(named: countries[2]), for: .normal)
    
    title = "FLAG OF \(countries[correctAnswer].uppercased())"
  }

  @IBAction func buttonTapped(_ sender: UIButton) {
    
    var acTitle = ""
    
    if sender.tag == correctAnswer {
      title = "CORRECT!"
      score += 1
    } else {
      title = "WRONG!"
      acTitle = "\(title!) That’s the flag of \(countries[sender.tag].uppercased())."
      score -= 1
    }
    
    if numberOfQuestionsAsked < 10 {
      let ac = UIAlertController(title: acTitle, message: "Your score is \(score)", preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
      present(ac, animated: true, completion: nil)
    } else {
      let ac = UIAlertController(title: acTitle, message: """
      GOOD JOB!
      FINAL SCORE \(score) / \(numberOfQuestionsAsked) QUESTIONS.
      WANT TO PLAY AGAIN?
      """, preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: "RESTART", style: .default) { action in
        self.numberOfQuestionsAsked = 0
        self.score = 0
        self.askQuestion()
      })
      present(ac, animated: true, completion: nil)
    }
  }
  
  @objc func showCurrentScore() {
    let alert = UIAlertController(title: "CURRENT SCORE:", message: "\(score) out of \(numberOfQuestionsAsked) question(s) asked.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    present(alert, animated: true, completion: nil)
  }
}

