//
//  ViewController.swift
//  WordGame
//
//  Created by Alexander Kazakov on 3/27/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

  var allWords = [String]()
  var usedWords = [String]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "new word", style: .plain, target: self, action: #selector(startGame))
    
    if let file = Bundle.main.url(forResource: "start", withExtension: "txt") {
      if let startWords = try? String(contentsOf: file) {
        allWords = startWords.components(separatedBy: "\n")
      }
    }
    
    if allWords.isEmpty {
      allWords = ["silkworm"]
    }
    
    startGame()
  }

  @objc func startGame() {
    title = allWords.randomElement()
    usedWords.removeAll(keepingCapacity: true)
    tableView.reloadData()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return usedWords.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
    cell.textLabel?.text = usedWords[indexPath.row]
    return cell
  }

  @objc func promptForAnswer() {
    let ac = UIAlertController(title: "Enter answer:", message: nil, preferredStyle: .alert)
    ac.addTextField()
    
    let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
      guard let answer = ac?.textFields?[0].text else { return }
      self?.submit(answer)
    }
    
    ac.addAction(submitAction)
    present(ac, animated: true)
  }
  
  func submit( _ answer: String) {
    let lowerAnswer = answer.lowercased()
    
    if isPossible(word: lowerAnswer) {
      if isOriginal(word: lowerAnswer) {
        if isReal(word: lowerAnswer) {
          usedWords.insert(lowerAnswer, at: 0)
          
          let indexPath = IndexPath(row: 0, section: 0)
          tableView.insertRows(at: [indexPath], with: .automatic)
          
          return
        } else {
          showErrorMessage(title: "Word not recognized", message: "You can't just make them up, you know!")
        }
      } else {
        showErrorMessage(title: "Word already used", message: "Be more original!")
      }
    } else {
      guard let title = title else { return }
      
      let errorTitle = "Word not possible"
      let errorMessage: String
      
      if lowerAnswer.count < 3 {
        errorMessage = "The word has to be 3 or more letters long."
      } else if lowerAnswer == title.lowercased() {
        errorMessage = "The word is the same as a given word. Don't cheat!"
      } else {
        errorMessage = "You can't spell that word from \(title.lowercased())."
      }
      
      showErrorMessage(title: errorTitle, message: errorMessage)
    }
  }
  
  func isPossible(word: String) -> Bool {
    
    if word.count < 3 { return false }
    if word == title?.lowercased() { return false }
    
    guard var tempWord = title?.lowercased() else { return false }
    for letter in word {
      if let position = tempWord.firstIndex(of: letter) {
        tempWord.remove(at: position)
      } else {
        return false
      }
    }
    
    return true
  }
  
  func isOriginal(word: String) -> Bool {
    return !usedWords.contains(word)
  }
  
  func isReal(word: String) -> Bool {
    let checker = UITextChecker()
    let range = NSRange(location: 0, length: word.utf16.count)
    let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
    return misspelledRange.location == NSNotFound
  }
  
  func showErrorMessage(title: String, message: String) {
    let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    present(ac, animated: true, completion: nil)
  }
  
}

