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
  var livesCount = 7 {
    didSet {
      navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Lives: \(livesCount)", style: .done, target: nil, action: nil)
    }
  }
  var score = 0 {
    didSet {
      navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Score: \(score)", style: .done, target: nil, action: nil)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    drawKeyboard()
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Lives: \(livesCount)", style: .done, target: nil, action: nil)
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Score: \(score)", style: .done, target: nil, action: nil)
    
    nextLevel(fromBeginning: true)
  }

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
      letterLabel.textColor = .black
      letterLabel.textAlignment = .center
      letterLabel.backgroundColor = .gray
      
      // Fill letter label with either placeholder or character (if that character is not present on the keyboard below)
      if acceptableLetters.contains(letter) {
        letterLabel.text = " "
      } else {
        letterLabel.text = String(letter)
        letterLabel.backgroundColor = .white
      }
      letterLabelsArray.append(letterLabel)
      wordStackView.addArrangedSubview(letterLabel)
    }
    
  }
  
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
  
    for row in keyboardLetters {
      
      let rowStackView = UIStackView()
      rowStackView.axis = .horizontal
      rowStackView.distribution = .equalSpacing
      rowStackView.spacing = 5
      keyboardView.addArrangedSubview(rowStackView)
      
      for letter in row.split(separator: " ") {
        let button = UIButton(type: .system)
        button.setTitle(letter.capitalized, for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.sizeToFit()
        
        button.addTarget(self, action: #selector(keyboardButtonPressed), for: .touchUpInside)
        keyboardArray.append(button)
        
        rowStackView.addArrangedSubview(button)
      }
    }
    
  }
  
  @objc func keyboardButtonPressed(sender: UIButton) {
    guard let selectedLetter = sender.titleLabel?.text?.uppercased() else { fatalError("No keyboard button letter attached.") }
    
    var letterFound = false
    for (index, letter) in levelWord.uppercased().enumerated() {
      
      // Highlight the letter as used
      sender.isEnabled = false
      sender.backgroundColor = .gray
      
      // pressed button letter matches one of the letters in the word
      if letter == Character(selectedLetter) {
        letterLabelsArray[index].text = selectedLetter
        letterFound = true
      }
    }
    
    let guessedWord = letterLabelsArray.reduce("") { (result, label) -> String in
      return result + (label.text ?? "")
    }
   
    if levelWord.capitalized == guessedWord.capitalized {
      let vc = UIAlertController(title: "YOU GOT IT", message: "Want to play again?", preferredStyle: .alert)
      vc.addAction(UIAlertAction(title: "Next Level", style: .default, handler: { [weak self] (action) in
        self?.nextLevel()
      }))
      present(vc, animated: true)
      return
    }
    
    
    // subtract live if no letters were matched
    if !letterFound {
      livesCount -= 1
    
      if livesCount <= 0 {
        let vc = UIAlertController(title: "GAME OVER", message: "Correct Answer: \(levelWord!).", preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "Play Again?", style: .default, handler: { [weak self] (action) in
          self?.nextLevel(fromBeginning: true)
        }))
        present(vc, animated: true)
      } else {
        
        // Present self-disappearing view
        let vc = UIAlertController(title: "WRONG", message: "Attempts Left: \(livesCount)", preferredStyle: .actionSheet)
        vc.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(vc, animated: true)
        
      }
    }
    
  }
  
  @objc func nextLevel(fromBeginning: Bool = false) {
    letterLabelsArray.removeAll()
    let labelsSubview = view.viewWithTag(22)
    labelsSubview?.removeFromSuperview()
    livesCount = 7
    score = (fromBeginning) ? 0 : score + 1
    levelWord = getLevelWord()
    drawWord()
    keyboardArray.forEach { (button) in
      button.isEnabled = true
      button.backgroundColor = .black
    }
    title = "Country: \(levelWord.count) letters"
  }
  
}

