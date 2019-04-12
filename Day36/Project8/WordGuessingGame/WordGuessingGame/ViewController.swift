//
//  ViewController.swift
//  WordGuessingGame
//
//  Created by Alexander Kazakov on 4/10/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  var cluesLabel: UILabel!
  var answersLabel: UILabel!
  var currentAnswer: UITextField!
  var scoreLabel: UILabel!
  var letterButtons = [UIButton]()
  
  var activatedButtons = [UIButton]()
  var solutions = [String]()
  
  var correctAnswers = 0
  var score = 0 {
    didSet {
      scoreLabel.text = "Score: \(score)"
    }
  }
  var level = 1
  
  override func loadView() {
    
    view = UIView()
    view.backgroundColor = .white
    
    scoreLabel = UILabel()
    scoreLabel.translatesAutoresizingMaskIntoConstraints = false
    scoreLabel.textAlignment = .right
    scoreLabel.text = "Score: 0"
    view.addSubview(scoreLabel)
    
    cluesLabel = UILabel()
    cluesLabel.translatesAutoresizingMaskIntoConstraints = false
    cluesLabel.font = UIFont.systemFont(ofSize: 20)
    cluesLabel.text = "CLUES"
    cluesLabel.numberOfLines = 0
    cluesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
    view.addSubview(cluesLabel)
    
    answersLabel = UILabel()
    answersLabel.translatesAutoresizingMaskIntoConstraints = false
    answersLabel.font = UIFont.systemFont(ofSize: 20)
    answersLabel.text = "ANSWERS"
    answersLabel.textAlignment = .right
    answersLabel.numberOfLines = 0
    answersLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
    view.addSubview(answersLabel)
    
    currentAnswer = UITextField()
    currentAnswer.translatesAutoresizingMaskIntoConstraints = false
    currentAnswer.placeholder = "TAP LETTERS TO GUESS"
    currentAnswer.textAlignment = .center
    currentAnswer.font = UIFont.systemFont(ofSize: 35)
    currentAnswer.isUserInteractionEnabled = false
    currentAnswer.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
    view.addSubview(currentAnswer)
    
    let submit = UIButton(type: .system)
    submit.translatesAutoresizingMaskIntoConstraints = false
    submit.setTitle("SUBMIT", for: .normal)
    submit.titleLabel?.font = UIFont.systemFont(ofSize: 30)
    submit.backgroundColor = UIColor(red:0.19, green:0.53, blue:1.00, alpha:1.0)
    submit.setTitleColor(.white, for: .normal)
    submit.layer.cornerRadius = 5
    submit.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    submit.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
    view.addSubview(submit)
    
    let clear = UIButton(type: .system)
    clear.translatesAutoresizingMaskIntoConstraints = false
    clear.setTitle("CLEAR", for: .normal)
    clear.titleLabel?.font = UIFont.systemFont(ofSize: 30)
    clear.backgroundColor = UIColor(red:0.19, green:0.53, blue:1.00, alpha:1.0)
    clear.setTitleColor(.white, for: .normal)
    clear.layer.cornerRadius = 5
    clear.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    clear.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
    view.addSubview(clear)
    
    let buttonsView = UIView()
    buttonsView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(buttonsView)
    
    NSLayoutConstraint.activate([
      scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      scoreLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50),
      
      cluesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
      cluesLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 100),
      cluesLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.6, constant: -100),
      
      answersLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
      answersLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -100),
      answersLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.4, constant: -100),
      answersLabel.heightAnchor.constraint(equalTo: cluesLabel.heightAnchor),
      
      currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      currentAnswer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
      currentAnswer.topAnchor.constraint(equalTo: cluesLabel.bottomAnchor, constant: 40),
      
      submit.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor, constant: 50),
      submit.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -88),
      submit.heightAnchor.constraint(equalToConstant: 44),
      
      clear.topAnchor.constraint(equalTo: submit.topAnchor),
      clear.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 88),
      clear.heightAnchor.constraint(equalTo: submit.heightAnchor),
      
      buttonsView.widthAnchor.constraint(equalToConstant: 750),
      buttonsView.heightAnchor.constraint(equalToConstant: 320),
      buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      buttonsView.topAnchor.constraint(equalTo: submit.bottomAnchor, constant: 20),
      buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
      
    ])
    
    let width = 150
    let height = 80
    
    for row in 0..<4 {
      for column in 0..<5 {
        let letterButton = UIButton(type: .system)
        
        letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        letterButton.backgroundColor = UIColor(red:0.36, green:0.72, blue:0.36, alpha:1.0)
        letterButton.setTitleColor(.white, for: .normal)
        letterButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        
        let frame = CGRect(x: column * width, y: row * height, width: width, height: height)
        letterButton.frame = frame
        letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
        buttonsView.addSubview(letterButton)
        letterButtons.append(letterButton)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadLevel()
  }
  
  @objc func letterTapped(_ sender: UIButton) {
    guard let buttonLabel = sender.titleLabel?.text else { return }
    currentAnswer.text?.append(contentsOf: buttonLabel)
    activatedButtons.append(sender)
    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
      sender.alpha = 0
    })
  }
  
  @objc func submitTapped(_ sender: UIButton) {
    guard let answer = currentAnswer.text, let answerIndex = solutions.firstIndex(of: answer) else {
      let ac = UIAlertController(title: "WRONG", message: "Unfortunately not the right word.", preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: nil))
      present(ac, animated: true, completion: nil)
      score = (score > 0) ? score - 1 : 0
      return
    }
    activatedButtons.removeAll()
    
    var answersLabelArray = answersLabel.text?.split(separator: "\n")
    answersLabelArray?[answerIndex] = Substring(answer)
    answersLabel.text = answersLabelArray?.joined(separator: "\n")
    
    score += 1
    correctAnswers += 1
    currentAnswer.text = ""
    
    if correctAnswers == solutions.count {
      let ac = UIAlertController(title: "All Done!", message: "Do you want to proceed to next level?", preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: "PROCEED", style: .default, handler: nextLevel))
      present(ac, animated: true, completion: nil)
    }
  }
  
  func nextLevel(sender: UIAlertAction) {
    for button in letterButtons {
      button.alpha = 1
    }
    level += 1
    solutions.removeAll(keepingCapacity: true)
    loadLevel()
  }
  
  @objc func clearTapped(_ sender: UIButton) {
    currentAnswer.text = ""
    
    for button in activatedButtons {
      button.alpha = 1
    }
    
    activatedButtons.removeAll()
  }
  
  func loadLevel() {
    var clueString = ""
    var solutionsString = ""
    var letterBits = [String]()
    
    if let levelFileURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") {
      if let levelContents = try? String(contentsOf: levelFileURL) {
        var lines = levelContents.components(separatedBy: "\n")
        lines.shuffle()
        
        for (index, line) in lines.enumerated() {
          let parts = line.components(separatedBy: ": ")
          let answer = parts[0]
          let clue = parts[1]
          
          clueString += "\(index + 1). \(clue)\n"
          
          let solutionWord = answer.replacingOccurrences(of: "|", with: "")
          solutionsString += "\(solutionWord.count) letters\n"
          solutions.append(solutionWord)
          
          let bits = answer.components(separatedBy: "|")
          letterBits += bits
        }
      }
    }
    cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
    answersLabel.text = solutionsString.trimmingCharacters(in: .whitespacesAndNewlines)
    
    letterButtons.shuffle()
    
    if letterButtons.count == letterBits.count {
      for i in 0..<letterButtons.count {
        letterButtons[i].setTitle(letterBits[i], for: .normal)
      }
    }
  }
  
}

