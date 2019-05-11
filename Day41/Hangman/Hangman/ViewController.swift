//
//  ViewController.swift
//  Hangman
//
//  Created by Alexander Kazakov on 4/16/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  var levelWord: String!
  var keyboardArray = [UIButton]()
  var letterLabelsArray = [UILabel]()
  let keyboardLetters = ["q w e r t y u i o p", "a s d f g h j k l", "z x c v b n m"]
  let livesLabel = UIButton()
  let scoreLabel = UIButton()
  var livesCount = 7 {
    didSet {
      livesLabel.setTitle("Lives: \(livesCount)", for: .normal)
    }
  }
  var score = 0 {
    didSet {
      scoreLabel.setTitle("Score: \(score)", for: .normal)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "HANGMAN"
    view.backgroundColor = UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
    
    drawUIElements()
    getLevel(fromBeginning: true)
  }
  
  func drawUIElements() {
    drawLivesLabel()
    drawScoresLabel()
    drawKeyboard()
  }
  
  func drawLivesLabel() {
    livesLabel.isUserInteractionEnabled = false
    livesLabel.setTitle("Lives: \(livesCount)", for: .normal)
    livesLabel.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    livesLabel.backgroundColor = UIColor(red:0.24, green:0.60, blue:0.44, alpha:1.0)
    livesLabel.setTitleColor(.white, for: .normal)
    livesLabel.layer.cornerRadius = 10
    livesLabel.titleEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    livesLabel.translatesAutoresizingMaskIntoConstraints = false
    livesLabel.sizeToFit()
    view.addSubview(livesLabel)
    
    NSLayoutConstraint.activate([
      livesLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
      livesLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
      livesLabel.widthAnchor.constraint(equalToConstant: 100)
      //livesLabel.heightAnchor.constraint(equalToConstant: 50)
      ])
  }
  
  func drawScoresLabel() {
    livesLabel.isUserInteractionEnabled = false
    scoreLabel.setTitle("Score: \(score)", for: .normal)
    scoreLabel.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    scoreLabel.backgroundColor = UIColor(red:0.24, green:0.60, blue:0.44, alpha:1.0)
    scoreLabel.setTitleColor(.white, for: .normal)
    scoreLabel.layer.cornerRadius = 10
    scoreLabel.titleEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    scoreLabel.translatesAutoresizingMaskIntoConstraints = false
    livesLabel.sizeToFit()
    view.addSubview(scoreLabel)
    
    NSLayoutConstraint.activate([
      
      scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
      scoreLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
      scoreLabel.widthAnchor.constraint(equalToConstant: 100)
      //scoreLabel.heightAnchor.constraint(equalToConstant: 50)
      ])
  }
  
  /**
   Retreives a random word from the words text file.
   
   - Returns: A random word.
  */
  func getLevelWord() -> String {
    let bundleURL = Bundle.main.bundleURL
    
    do {
      let words = try String(contentsOf: URL(fileURLWithPath: "Countries.txt", relativeTo: bundleURL)).split(separator: "\n")
      return String(words.randomElement()!)
    } catch {
      print(error)
      fatalError("Unable to parse words file")
    }
  }

  /**
    Creates a collection of UILabels matching the number of letters in the levelWord.
  */
  func drawWord() {
    let acceptableLetters = keyboardLetters.joined(separator: "").replacingOccurrences(of: " ", with: "")
    
    let wordStackView = UIStackView()
    wordStackView.tag = 22
    wordStackView.translatesAutoresizingMaskIntoConstraints = false
    wordStackView.axis = .horizontal
    wordStackView.alignment = .center
    wordStackView.distribution = .fillEqually
    wordStackView.spacing = 5
    view.addSubview(wordStackView)
    
    wordStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    wordStackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -10).isActive = true
    wordStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -25).isActive = true
    
    for letter in levelWord.lowercased() {
      let letterLabel = UILabel()
      letterLabel.font = UIFont.systemFont(ofSize: 25, weight: .bold)
      letterLabel.textColor = .white
      letterLabel.textAlignment = .center
      letterLabel.adjustsFontSizeToFitWidth = true
      letterLabel.backgroundColor = UIColor(red:0.00, green:0.45, blue:0.85, alpha:1.0)
      letterLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
      
      // Fill letter label with either placeholder or word letter (if that character is not present on the generated keyboard)
      if acceptableLetters.contains(letter) {
        letterLabel.text = " "
      } else {
        letterLabel.text = String(letter)
        letterLabel.backgroundColor = view.backgroundColor
      }
      letterLabelsArray.append(letterLabel)
      wordStackView.addArrangedSubview(letterLabel)
    }
    
  }
  
  /**
    Creates a virtual keyboard towards the bottom of the screen to be used during the game.
    Represented as three horizontal stackViews inside a vertical stackView.
  */
  func drawKeyboard() {
    
    let keyboardView = UIStackView()
    keyboardView.translatesAutoresizingMaskIntoConstraints = false
    keyboardView.axis = .vertical
    keyboardView.alignment = .center
    keyboardView.distribution = .equalSpacing
    keyboardView.spacing = 5
    view.addSubview(keyboardView)
    
    keyboardView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    keyboardView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
    keyboardView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25).isActive = true
  
    for (index, row) in keyboardLetters.enumerated() {
      
      let rowStackView = UIStackView()
      rowStackView.axis = .horizontal
      rowStackView.distribution = .fillEqually
      rowStackView.spacing = 5
      keyboardView.addArrangedSubview(rowStackView)
      
      let offset = view.frame.width / 10 + rowStackView.spacing
      switch (index) {
      case 1:  rowStackView.widthAnchor.constraint(equalTo: keyboardView.widthAnchor, constant: -offset).isActive = true
      case 2:  rowStackView.widthAnchor.constraint(equalTo: keyboardView.widthAnchor, constant: -(offset * 3)).isActive = true
      default: rowStackView.widthAnchor.constraint(equalTo: keyboardView.widthAnchor).isActive = true
      }
      
      for letter in row.split(separator: " ") {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red:0.52, green:0.08, blue:0.29, alpha:1.0)
        
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.setTitle(letter.capitalized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        button.sizeToFit()
        
        button.addTarget(self, action: #selector(keyboardButtonPressed), for: .touchUpInside)
        keyboardArray.append(button)
        
        rowStackView.addArrangedSubview(button)
      }
    }
    
  }
  
  /**
   Virtual Keyboard touch handler.
   - Parameters: sender: virtual keyboard button that was pressed.
  */
  @objc func keyboardButtonPressed(sender: UIButton) {
    
    // Retrieves the String representation of the selected letter
    guard let selectedLetter = sender.titleLabel?.text?.uppercased() else { fatalError("No keyboard button letter attached.") }
    
    var letterFound = false
    for (index, letter) in levelWord.uppercased().enumerated() {
      
      // Highlight the letter as used
      sender.isEnabled = false
      sender.backgroundColor = .gray
      
      // Here index ofthe levelWord matches index of the letterLabelsArray (since it was generated from the levelWord prior).
      if letter == Character(selectedLetter) {
        letterLabelsArray[index].text = selectedLetter
        letterFound = true
      }
    }
    
    switch letterFound {
    case true:
      // Combine all the uncovered letters in the labels to form a guessed word at the moment.
      let guessedWord = letterLabelsArray.reduce("") { (result, label) -> String in
        return result + (label.text ?? "")
      }
      // If guessed word matches levelWord prompt for next level.
      if levelWord.capitalized == guessedWord.capitalized {
        let vc = UIAlertController(title: "YOU GOT IT", message: "Want to play again?", preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "Next Level", style: .default, handler: { [weak self] (action) in
          self?.getLevel()
        }))
        present(vc, animated: true)
        return
      }
    case false:
      livesCount -= 1
      
      if livesCount <= 0 {
        let vc = UIAlertController(title: "GAME OVER", message: "Correct Answer: '\(levelWord!)'.", preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "Play Again?", style: .default, handler: { [weak self] (action) in
          self?.getLevel(fromBeginning: true)
        }))
        present(vc, animated: true)
      } else {
        
        // Present self-disappearing view
        let vc = UIAlertController(title: "No '\(selectedLetter)' found.", message: "Attempts Left: \(livesCount)", preferredStyle: .actionSheet)
        vc.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(vc, animated: true)
        
      }
    }
    
  }
  
  /**
   Loads new level.
     - Resets UILabels Array and removes current labels from the view
     - Resets lives count to default
     - Increments score count
     - Retrieves a new word
     - Generates new UILabels for a new word
   
   - Parameters:
     - fromBeginning: if set to **true** the score is going to be reset to 0
  */
  @objc func getLevel(fromBeginning: Bool = false) {
    
    let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromLeft]
    let letterLabelsCount = letterLabelsArray.count
    var letterLabelIncrement = 0
    for letterLabel in letterLabelsArray {
      UIView.transition(with: letterLabel, duration: 1, options: transitionOptions, animations: {
        letterLabel.text = ""
      }) { [weak self] (finished) in
        letterLabelIncrement += 1
        
        // Checks if all animations finished
        if (letterLabelIncrement == letterLabelsCount) {
          self?.finishGetLevel(fromBeginning: fromBeginning)
        }
      }
    }
    
    if letterLabelsArray.isEmpty {
      finishGetLevel(fromBeginning: fromBeginning)
    }
  }
  
  func finishGetLevel(fromBeginning: Bool = false) {
    let labelsSubview = view.viewWithTag(22)
    labelsSubview?.removeFromSuperview()
    letterLabelsArray.removeAll()
    
    keyboardArray.forEach { (button) in
      button.isEnabled = true
      button.backgroundColor = UIColor(red:0.52, green:0.08, blue:0.29, alpha:1.0)
    }
    
    livesCount = 7
    score      = (fromBeginning) ? 0 : score + 1
    levelWord  = getLevelWord()
    drawWord()
  }
  
}

