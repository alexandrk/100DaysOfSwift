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
  var score = 0 {
    didSet {
      navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SCORE: \(score)", style: .plain, target: self, action: #selector(showCurrentScore))
    }
  }
  var highestScore = 0
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
    
    highestScore = UserDefaults.standard.integer(forKey: "highestScore")
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SCORE: \(score)", style: .plain, target: self, action: #selector(showCurrentScore))
    
    askQuestion()
  }

  @objc func askQuestion(action: UIAlertAction! = nil) {
    
    numberOfQuestionsAsked += 1
    
    countries.shuffle()
    correctAnswer = Int.random(in: 0...2)
    
    button1.setImage(UIImage(named: countries[0]), for: .normal)
    button2.setImage(UIImage(named: countries[1]), for: .normal)
    button3.setImage(UIImage(named: countries[2]), for: .normal)
    
    title = "FLAG OF \(countries[correctAnswer].uppercased())"
  }

  @IBAction func buttonTapped(_ sender: UIButton) {
    
    var message = ""
    var color: UIColor!
    
    if sender.tag == correctAnswer {
      message = "CORRECT!"
      color = UIColor(red: 0, green: 0.63, blue: 0.42, alpha: 1.0)
      score += 1
    } else {
      message = "WRONG!"
      message += "\nThat’s \(countries[sender.tag].uppercased())."
      color = UIColor(red: 0.63, green: 0.04, blue: 0.03, alpha: 1.0)
      score -= 1
    }
    
    if score > highestScore {
      highestScore = score
      save()
      color = .purple
      message = "!YAY!\nNEW HIGH SCORE: \n\(score)"
      infoLabel(message: message, backgroundColor: color)
    } else {
      infoLabel(message: message, backgroundColor: color)
    }
    perform(#selector(askQuestion), with: nil, afterDelay: 1)
    
  }
  
  @objc func showCurrentScore() {
    let alert = UIAlertController(title: "Score Table:", message: "Questions Asked: \(numberOfQuestionsAsked)\nCurrent Score: \(score)\nHighest Score: \(highestScore)", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
  func save() {
    UserDefaults.standard.set(highestScore, forKey: "highestScore")
  }
  
  func infoLabel(message: String, backgroundColor: UIColor) {
    
    let label = UILabel()
    label.numberOfLines = 0
    label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
    label.backgroundColor = backgroundColor
    label.textColor = .white
    label.textAlignment = .center
    label.layer.cornerRadius = 10
    label.clipsToBounds = true
    label.layer.borderWidth = 3
    label.layer.borderColor = UIColor.black.cgColor
    label.alpha = 0
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = message
    
    view.addSubview(label)
    
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
      label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
      label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
      label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
      label.heightAnchor.constraint(equalToConstant: 150)
      ])
    
    UIView.animate(withDuration: 0.7, animations: { [weak label] in
      label?.alpha = 1
    }) { (completed) in
      UIView.animate(withDuration: 0.5, animations: {
        label.alpha = 0
      }, completion: { (completed) in
        label.removeFromSuperview()
      })
    }
    
  }
  
}

